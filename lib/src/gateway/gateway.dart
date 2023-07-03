import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/gateway/event_parser.dart';
import 'package:nyxx/src/gateway/message.dart';
import 'package:nyxx/src/gateway/shard.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/events/application_command.dart';
import 'package:nyxx/src/models/gateway/events/auto_moderation.dart';
import 'package:nyxx/src/models/gateway/events/channel.dart';
import 'package:nyxx/src/models/gateway/events/guild.dart';
import 'package:nyxx/src/models/gateway/events/integration.dart';
import 'package:nyxx/src/models/gateway/events/interaction.dart';
import 'package:nyxx/src/models/gateway/events/invite.dart';
import 'package:nyxx/src/models/gateway/events/message.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/gateway/events/ready.dart';
import 'package:nyxx/src/models/gateway/events/stage_instance.dart';
import 'package:nyxx/src/models/gateway/events/voice.dart';
import 'package:nyxx/src/models/gateway/events/webhook.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// Handles the connection to Discord's Gateway with shards, manages the client's cache based on Gateway events and provides an interface to the Gateway.
class Gateway extends GatewayManager with EventParser {
  @override
  final NyxxGateway client;

  /// The [GatewayBot] instance used to configure this [Gateway].
  final GatewayBot gatewayBot;

  /// The total number of shards running in the client's session.
  final int totalShards;

  /// The IDs of the shards running in this [Gateway].
  final List<int> shardIds;

  /// The shards running in this [Gateway].
  final List<Shard> shards;

  /// A stream of messages received from all shards.
  Stream<ShardMessage> get messages => _messagesController.stream;

  final StreamController<ShardMessage> _messagesController = StreamController.broadcast();

  /// A stream of dispatch events received from all shards.
  Stream<DispatchEvent> get events => messages.map((message) {
        if (message is! EventReceived) {
          return null;
        }

        final event = message.event;
        if (event is! RawDispatchEvent) {
          return null;
        }

        return parseDispatchEvent(event);
      }).whereType<DispatchEvent>();

  bool _closing = false;

  /// Create a new [Gateway].
  Gateway(this.client, this.gatewayBot, this.shards, this.totalShards, this.shardIds) : super.create() {
    for (final shard in shards) {
      shard.listen(
        (message) {
          if (message is ErrorReceived) {
            shard.logger.warning('Received error: ${message.error}', message.error, message.stackTrace);
          }

          _messagesController.add(message);
        },
        onError: _messagesController.addError,
        onDone: () async {
          if (_closing) {
            return;
          }

          await client.close();

          throw ShardDisconnectedError(shard);
        },
      );
    }

    // TODO: ApplicationCommandPermissionsUpdateEvent

    // Handle all events which should update cache.
    events.listen((event) => switch (event) {
          ReadyEvent(:final user) => client.users.cache[user.id] = user,
          ChannelCreateEvent(:final channel) || ChannelUpdateEvent(:final channel) => client.channels.cache[channel.id] = channel,
          ChannelDeleteEvent(:final channel) => client.channels.cache.remove(channel.id),
          ThreadCreateEvent(:final thread) || ThreadUpdateEvent(:final thread) => client.channels.cache[thread.id] = thread,
          ThreadDeleteEvent(:final thread) => client.channels.cache.remove(thread.id),
          ThreadListSyncEvent(:final threads) => client.channels.cache..addEntries(threads.map((thread) => MapEntry(thread.id, thread))),
          final GuildCreateEvent event => () {
              client.guilds.cache[event.guild.id] = event.guild;

              event.guild.members.cache.addEntries(event.members.map((member) => MapEntry(member.id, member)));
              client.channels.cache.addEntries(event.channels.map((channel) => MapEntry(channel.id, channel)));
              client.channels.cache.addEntries(event.threads.map((thread) => MapEntry(thread.id, thread)));
              client.channels.stageInstanceCache.addEntries(event.stageInstances.map((instance) => MapEntry(instance.id, instance)));
              event.guild.scheduledEvents.cache.addEntries(event.scheduledEvents.map((event) => MapEntry(event.id, event)));
              client.voice.cache.addEntries(event.voiceStates.map((state) => MapEntry(state.cacheKey, state)));
            }(),
          GuildUpdateEvent(:final guild) => client.guilds.cache[guild.id] = guild,
          GuildDeleteEvent(:final guild, isUnavailable: false) => client.guilds.cache.remove(guild.id),
          GuildMemberAddEvent(:final guildId, :final member) ||
          GuildMemberUpdateEvent(:final guildId, :final member) =>
            client.guilds[guildId].members.cache[member.id] = member,
          GuildMemberRemoveEvent(:final guildId, :final user) => client.guilds[guildId].members.cache.remove(user.id),
          GuildMembersChunkEvent(:final guildId, :final members) => client.guilds[guildId].members.cache
            ..addEntries(members.map((member) => MapEntry(member.id, member))),
          GuildRoleCreateEvent(:final guildId, :final role) ||
          GuildRoleUpdateEvent(:final guildId, :final role) =>
            client.guilds[guildId].roles.cache[role.id] = role,
          GuildRoleDeleteEvent(:final guildId, :final roleId) => client.guilds[guildId].roles.cache.remove(roleId),
          MessageCreateEvent(:final message) => (client.channels[message.channelId] as PartialTextChannel).messages.cache[message.id] = message,
          MessageDeleteEvent(id: final messageId, :final channelId) =>
            MessageManager(client.options.messageCacheConfig, client, channelId: channelId).cache.remove(messageId),
          MessageBulkDeleteEvent(ids: final messageIds, :final channelId) =>
            // ignore: avoid_function_literals_in_foreach_calls
            messageIds..forEach((messageId) => MessageManager(client.options.messageCacheConfig, client, channelId: channelId).cache.remove(messageId)),
          UserUpdateEvent(:final user) => client.users.cache[user.id] = user,
          StageInstanceCreateEvent(:final instance) || StageInstanceUpdateEvent(:final instance) => client.channels.stageInstanceCache[instance.channelId] =
              instance,
          StageInstanceDeleteEvent(:final instance) => client.channels.stageInstanceCache.remove(instance.channelId),
          GuildScheduledEventCreateEvent(:final event) ||
          GuildScheduledEventUpdateEvent(:final event) =>
            client.guilds[event.guildId].scheduledEvents.cache[event.id] = event,
          GuildScheduledEventDeleteEvent(:final event) => client.guilds[event.guildId].scheduledEvents.cache.remove(event.id),
          AutoModerationRuleCreateEvent(:final rule) ||
          AutoModerationRuleUpdateEvent(:final rule) =>
            client.guilds[rule.guildId].autoModerationRules.cache[rule.id] = rule,
          AutoModerationRuleDeleteEvent(:final rule) => client.guilds[rule.guildId].autoModerationRules.cache.remove(rule.id),
          IntegrationCreateEvent(:final guildId, :final integration) ||
          IntegrationUpdateEvent(:final guildId, :final integration) =>
            client.guilds[guildId].integrations.cache[integration.id] = integration,
          IntegrationDeleteEvent(:final id, :final guildId) => client.guilds[guildId].integrations.cache.remove(id),
          GuildAuditLogCreateEvent(:final entry, :final guildId) => client.guilds[guildId].auditLogs.cache[entry.id] = entry,
          VoiceStateUpdateEvent(:final state) => client.voice.cache[state.cacheKey] = state,
          GuildEmojisUpdateEvent(:final guildId, :final emojis) => client.guilds[guildId].emojis.cache
            ..clear()
            ..addEntries(emojis.map((emoji) => MapEntry(emoji.id, emoji))),
          GuildStickersUpdateEvent(:final guildId, :final stickers) =>
            client.guilds[guildId].stickers.cache.addEntries(stickers.map((sticker) => MapEntry(sticker.id, sticker))),
          _ => null,
        });
  }

  /// Connect to the gateway using the provided [client] and [gatewayBot] configuration.
  static Future<Gateway> connect(NyxxGateway client, GatewayBot gatewayBot) async {
    final logger = Logger('${client.options.loggerName}.Gateway');

    final totalShards = client.apiOptions.totalShards ?? gatewayBot.shards;
    final List<int> shardIds = client.apiOptions.shards ?? List.generate(totalShards, (i) => i);

    logger
      ..info('Connecting ${shardIds.length}/$totalShards shards')
      ..fine('Shard IDs: $shardIds')
      ..fine(
        'Gateway URL: ${gatewayBot.url}, Recommended Shards: ${gatewayBot.shards}, Max Concurrency: ${gatewayBot.sessionStartLimit.maxConcurrency},'
        ' Remaining Session Starts: ${gatewayBot.sessionStartLimit.remaining}, Reset After: ${gatewayBot.sessionStartLimit.resetAfter}',
      );

    if (gatewayBot.sessionStartLimit.remaining < 50) {
      logger.warning('${gatewayBot.sessionStartLimit.remaining} session starts remaining');
    }

    if (gatewayBot.sessionStartLimit.remaining < client.options.minimumSessionStarts) {
      throw OutOfRemainingSessionsError(gatewayBot);
    }

    assert(
      shardIds.every((element) => element < totalShards),
      'Shard ID exceeds total shard count',
    );

    assert(
      shardIds.every((element) => element >= 0),
      'Invalid shard ID',
    );

    assert(
      shardIds.toSet().length == shardIds.length,
      'Duplicate shard ID',
    );

    assert(
      client.apiOptions.compression != GatewayCompression.payload || client.apiOptions.payloadFormat != GatewayPayloadFormat.etf,
      'Cannot enable payload compression when using the ETF payload format',
    );

    const identifyDelay = Duration(seconds: 5);

    final shards = shardIds.indexed.map(((int, int) info) {
      final (index, id) = info;

      return Future.delayed(
        identifyDelay * (index ~/ gatewayBot.sessionStartLimit.maxConcurrency),
        () => Shard.connect(id, totalShards, client.apiOptions, gatewayBot.url, client),
      );
    });

    return Gateway(client, gatewayBot, await Future.wait(shards), totalShards, shardIds);
  }

  /// Close this [Gateway] instance, disconnecting all shards and closing the event streams.
  Future<void> close() async {
    _closing = true;
    await Future.wait(shards.map((shard) => shard.close()));
    _messagesController.close();
  }

  /// Compute the ID of the shard that handles events for [guildId].
  int shardIdFor(Snowflake guildId) => (guildId.value >> 22) % totalShards;

  /// Return the shard that handles events for [guildId].
  ///
  /// Throws an error if the shard handling events for [guildId] is not in this [Gateway] instance.
  Shard shardFor(Snowflake guildId) => shards.singleWhere((shard) => shard.id == shardIdFor(guildId));

  DispatchEvent parseDispatchEvent(RawDispatchEvent raw) {
    final mapping = {
      'READY': parseReady,
      'RESUMED': parseResumed,
      'APPLICATION_COMMAND_PERMISSIONS_UPDATE': parseApplicationCommandPermissionsUpdate,
      'AUTO_MODERATION_RULE_CREATE': parseAutoModerationRuleCreate,
      'AUTO_MODERATION_RULE_UPDATE': parseAutoModerationRuleUpdate,
      'AUTO_MODERATION_RULE_DELETE': parseAutoModerationRuleDelete,
      'AUTO_MODERATION_ACTION_EXECUTION': parseAutoModerationActionExecution,
      'CHANNEL_CREATE': parseChannelCreate,
      'CHANNEL_UPDATE': parseChannelUpdate,
      'CHANNEL_DELETE': parseChannelDelete,
      'THREAD_CREATE': parseThreadCreate,
      'THREAD_UPDATE': parseThreadUpdate,
      'THREAD_DELETE': parseThreadDelete,
      'THREAD_LIST_SYNC': parseThreadListSync,
      'THREAD_MEMBER_UPDATE': parseThreadMemberUpdate,
      'THREAD_MEMBERS_UPDATE': parseThreadMembersUpdate,
      'CHANNEL_PINS_UPDATE': parseChannelPinsUpdate,
      'GUILD_CREATE': parseGuildCreate,
      'GUILD_UPDATE': parseGuildUpdate,
      'GUILD_DELETE': parseGuildDelete,
      'GUILD_AUDIT_LOG_ENTRY_CREATE': parseGuildAuditLogCreate,
      'GUILD_BAN_ADD': parseGuildBanAdd,
      'GUILD_BAN_REMOVE': parseGuildBanRemove,
      'GUILD_EMOJIS_UPDATE': parseGuildEmojisUpdate,
      'GUILD_STICKERS_UPDATE': parseGuildStickersUpdate,
      'GUILD_INTEGRATIONS_UPDATE': parseGuildIntegrationsUpdate,
      'GUILD_MEMBER_ADD': parseGuildMemberAdd,
      'GUILD_MEMBER_REMOVE': parseGuildMemberRemove,
      'GUILD_MEMBER_UPDATE': parseGuildMemberUpdate,
      'GUILD_MEMBERS_CHUNK': parseGuildMembersChunk,
      'GUILD_ROLE_CREATE': parseGuildRoleCreate,
      'GUILD_ROLE_UPDATE': parseGuildRoleUpdate,
      'GUILD_ROLE_DELETE': parseGuildRoleDelete,
      'GUILD_SCHEDULED_EVENT_CREATE': parseGuildScheduledEventCreate,
      'GUILD_SCHEDULED_EVENT_UPDATE': parseGuildScheduledEventUpdate,
      'GUILD_SCHEDULED_EVENT_DELETE': parseGuildScheduledEventDelete,
      'GUILD_SCHEDULED_EVENT_USER_ADD': parseGuildScheduledEventUserAdd,
      'GUILD_SCHEDULED_EVENT_USER_REMOVE': parseGuildScheduledEventUserRemove,
      'INTEGRATION_CREATE': parseIntegrationCreate,
      'INTEGRATION_UPDATE': parseIntegrationUpdate,
      'INTEGRATION_DELETE': parseIntegrationDelete,
      'INVITE_CREATE': parseInviteCreate,
      'INVITE_DELETE': parseInviteDelete,
      'MESSAGE_CREATE': parseMessageCreate,
      'MESSAGE_UPDATE': parseMessageUpdate,
      'MESSAGE_DELETE': parseMessageDelete,
      'MESSAGE_DELETE_BULK': parseMessageBulkDelete,
      'MESSAGE_REACTION_ADD': parseMessageReactionAdd,
      'MESSAGE_REACTION_REMOVE': parseMessageReactionRemove,
      'MESSAGE_REACTION_REMOVE_ALL': parseMessageReactionRemoveAll,
      'MESSAGE_REACTION_REMOVE_EMOJI': parseMessageReactionRemoveEmoji,
      'PRESENCE_UPDATE': parsePresenceUpdate,
      'TYPING_START': parseTypingStart,
      'USER_UPDATE': parseUserUpdate,
      'VOICE_STATE_UPDATE': parseVoiceStateUpdate,
      'VOICE_SERVER_UPDATE': parseVoiceServerUpdate,
      'WEBHOOKS_UPDATE': parseWebhooksUpdate,
      'INTERACTION_CREATE': parseInteractionCreate,
      'STAGE_INSTANCE_CREATE': parseStageInstanceCreate,
      'STAGE_INSTANCE_UPDATE': parseStageInstanceUpdate,
      'STAGE_INSTANCE_DELETE': parseStageInstanceDelete,
    };

    return mapping[raw.name]?.call(raw.payload) ?? UnknownDispatchEvent(gateway: this, raw: raw);
  }

  ReadyEvent parseReady(Map<String, Object?> raw) {
    return ReadyEvent(
      gateway: this,
      version: raw['v'] as int,
      user: client.users.parse(raw['user'] as Map<String, Object?>),
      guilds: parseMany(
        raw['guilds'] as List<Object?>,
        (Map<String, Object?> raw) => PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds),
      ),
      sessionId: raw['session_id'] as String,
      gatewayResumeUrl: Uri.parse(raw['resume_gateway_url'] as String),
      shardId: (raw['shard'] as List<Object?>?)?[0] as int?,
      totalShards: (raw['shard'] as List<Object?>?)?[1] as int?,
      application: PartialApplication(
        id: Snowflake.parse((raw['application'] as Map<String, Object?>)['id']!),
        manager: client.applications,
      ),
    );
  }

  ResumedEvent parseResumed(Map<String, Object?> raw) {
    return ResumedEvent(
      gateway: this,
    );
  }

  ApplicationCommandPermissionsUpdateEvent parseApplicationCommandPermissionsUpdate(Map<String, Object?> raw) {
    return ApplicationCommandPermissionsUpdateEvent(
      gateway: this,
    );
  }

  AutoModerationRuleCreateEvent parseAutoModerationRuleCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleCreateEvent(
      gateway: this,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  AutoModerationRuleUpdateEvent parseAutoModerationRuleUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final rule = client.guilds[guildId].autoModerationRules.parse(raw);

    return AutoModerationRuleUpdateEvent(
      gateway: this,
      oldRule: client.guilds[guildId].autoModerationRules.cache[rule.id],
      rule: rule,
    );
  }

  AutoModerationRuleDeleteEvent parseAutoModerationRuleDelete(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleDeleteEvent(
      gateway: this,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  AutoModerationActionExecutionEvent parseAutoModerationActionExecution(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationActionExecutionEvent(
      gateway: this,
      guildId: guildId,
      action: client.guilds[guildId].autoModerationRules.parseAutoModerationAction(raw['action'] as Map<String, Object?>),
      ruleId: Snowflake.parse(raw['rule_id']!),
      triggerType: TriggerType.parse(raw['rule_trigger_type'] as int),
      userId: Snowflake.parse(raw['user_id']!),
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      messageId: maybeParse(raw['message_id'], Snowflake.parse),
      alertSystemMessageId: maybeParse(raw['alert_system_message_id'], Snowflake.parse),
      content: raw['content'] as String?,
      matchedKeyword: raw['matched_keyword'] as String?,
      matchedContent: raw['matched_content'] as String?,
    );
  }

  ChannelCreateEvent parseChannelCreate(Map<String, Object?> raw) {
    return ChannelCreateEvent(
      gateway: this,
      channel: client.channels.parse(raw),
    );
  }

  ChannelUpdateEvent parseChannelUpdate(Map<String, Object?> raw) {
    final channel = client.channels.parse(raw);

    return ChannelUpdateEvent(
      gateway: this,
      oldChannel: client.channels.cache[channel.id],
      channel: channel,
    );
  }

  ChannelDeleteEvent parseChannelDelete(Map<String, Object?> raw) {
    return ChannelDeleteEvent(
      gateway: this,
      channel: client.channels.parse(raw),
    );
  }

  ThreadCreateEvent parseThreadCreate(Map<String, Object?> raw) {
    return ThreadCreateEvent(
      gateway: this,
      thread: client.channels.parse(raw) as Thread,
    );
  }

  ThreadUpdateEvent parseThreadUpdate(Map<String, Object?> raw) {
    final thread = client.channels.parse(raw) as Thread;

    return ThreadUpdateEvent(
      gateway: this,
      oldThread: client.channels.cache[thread.id] as Thread?,
      thread: thread,
    );
  }

  ThreadDeleteEvent parseThreadDelete(Map<String, Object?> raw) {
    return ThreadDeleteEvent(
      gateway: this,
      thread: PartialChannel(
        id: Snowflake.parse(raw['id']!),
        manager: client.channels,
      ),
    );
  }

  ThreadListSyncEvent parseThreadListSync(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadListSyncEvent(
      gateway: this,
      guildId: guildId,
      channelIds: maybeParseMany(raw['channel_ids'], Snowflake.parse),
      threads: parseMany(
        raw['threads'] as List<Object?>,
        (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guildId) as Thread,
      ),
      members: parseMany(raw['members'] as List<Object?>, client.channels.parseThreadMember),
    );
  }

  ThreadMemberUpdateEvent parseThreadMemberUpdate(Map<String, Object?> raw) {
    return ThreadMemberUpdateEvent(
      gateway: this,
      member: client.channels.parseThreadMember(raw),
    );
  }

  ThreadMembersUpdateEvent parseThreadMembersUpdate(Map<String, Object?> raw) {
    return ThreadMembersUpdateEvent(
      gateway: this,
      id: Snowflake.parse(raw['id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
      memberCount: raw['member_count'] as int,
      addedMembers: maybeParseMany(raw['added_members'], client.channels.parseThreadMember),
      removedMemberIds: maybeParseMany(raw['removed_member_ids'], Snowflake.parse),
    );
  }

  ChannelPinsUpdateEvent parseChannelPinsUpdate(Map<String, Object?> raw) {
    return ChannelPinsUpdateEvent(
      gateway: this,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id']!),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
    );
  }

  UnavailableGuildCreateEvent parseGuildCreate(Map<String, Object?> raw) {
    if (raw['unavailable'] == true) {
      return UnavailableGuildCreateEvent(gateway: this, guild: PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds));
    }

    final guild = client.guilds.parse(raw);

    return GuildCreateEvent(
      gateway: this,
      guild: guild,
      joinedAt: DateTime.parse(raw['joined_at'] as String),
      isLarge: raw['large'] as bool,
      memberCount: raw['member_count'] as int,
      voiceStates: parseMany(raw['voice_states'] as List<Object?>, client.voice.parseVoiceState),
      members: parseMany(raw['members'] as List<Object?>, client.guilds[guild.id].members.parse),
      channels: parseMany(raw['channels'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as GuildChannel),
      threads: parseMany(raw['threads'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as Thread),
      presences: parseMany(raw['presences'] as List<Object?>, parsePresenceUpdate),
      stageInstances: parseMany(raw['stage_instances'] as List<Object?>, client.channels.parseStageInstance),
      scheduledEvents: parseMany(raw['guild_scheduled_events'] as List<Object?>, client.guilds[guild.id].scheduledEvents.parse),
    );
  }

  GuildUpdateEvent parseGuildUpdate(Map<String, Object?> raw) {
    final guild = client.guilds.parse(raw);

    return GuildUpdateEvent(
      gateway: this,
      oldGuild: client.guilds.cache[guild.id],
      guild: guild,
    );
  }

  GuildDeleteEvent parseGuildDelete(Map<String, Object?> raw) {
    return GuildDeleteEvent(
      gateway: this,
      guild: PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds),
      isUnavailable: raw['unavailable'] as bool,
    );
  }

  GuildAuditLogCreateEvent parseGuildAuditLogCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return GuildAuditLogCreateEvent(
      gateway: this,
      entry: client.guilds[guildId].auditLogs.parse(raw),
      guildId: guildId,
    );
  }

  GuildBanAddEvent parseGuildBanAdd(Map<String, Object?> raw) {
    return GuildBanAddEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildBanRemoveEvent parseGuildBanRemove(Map<String, Object?> raw) {
    return GuildBanRemoveEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildEmojisUpdateEvent parseGuildEmojisUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildEmojisUpdateEvent(
      gateway: this,
      guildId: guildId,
      emojis: parseMany(raw['emojis'] as List<Object?>, client.guilds[guildId].emojis.parse),
    );
  }

  GuildStickersUpdateEvent parseGuildStickersUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return GuildStickersUpdateEvent(
      gateway: this,
      guildId: guildId,
      stickers: parseMany(raw['stickers'] as List, client.guilds[guildId].stickers.parse),
    );
  }

  GuildIntegrationsUpdateEvent parseGuildIntegrationsUpdate(Map<String, Object?> raw) {
    return GuildIntegrationsUpdateEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  GuildMemberAddEvent parseGuildMemberAdd(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return GuildMemberAddEvent(
      gateway: this,
      guildId: guildId,
      member: client.guilds[guildId].members.parse(raw),
    );
  }

  GuildMemberRemoveEvent parseGuildMemberRemove(Map<String, Object?> raw) {
    return GuildMemberRemoveEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildMemberUpdateEvent parseGuildMemberUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    // TODO: The member received from the update has mute and deaf as nullable fields, which this parser does not.
    final member = client.guilds[guildId].members.parse(raw);

    return GuildMemberUpdateEvent(
      gateway: this,
      oldMember: client.guilds[guildId].members.cache[member.id],
      member: member,
      guildId: guildId,
    );
  }

  GuildMembersChunkEvent parseGuildMembersChunk(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildMembersChunkEvent(
      gateway: this,
      guildId: guildId,
      members: parseMany(raw['members'] as List<Object?>, client.guilds[guildId].members.parse),
      chunkIndex: raw['chunk_index'] as int,
      chunkCount: raw['chunk_count'] as int,
      notFound: maybeParseMany(raw['not_found'], Snowflake.parse),
      presences: maybeParseMany(raw['presences'], parsePresenceUpdate),
      nonce: raw['nonce'] as String?,
    );
  }

  GuildRoleCreateEvent parseGuildRoleCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildRoleCreateEvent(
      gateway: this,
      guildId: guildId,
      role: client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>),
    );
  }

  GuildRoleUpdateEvent parseGuildRoleUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final role = client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>);

    return GuildRoleUpdateEvent(
      gateway: this,
      guildId: guildId,
      oldRole: client.guilds[guildId].roles.cache[role.id],
      role: role,
    );
  }

  GuildRoleDeleteEvent parseGuildRoleDelete(Map<String, Object?> raw) {
    return GuildRoleDeleteEvent(
      gateway: this,
      roleId: Snowflake.parse(raw['role_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  GuildScheduledEventCreateEvent parseGuildScheduledEventCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventCreateEvent(
      gateway: this,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  GuildScheduledEventUpdateEvent parseGuildScheduledEventUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final event = client.guilds[guildId].scheduledEvents.parse(raw);

    return GuildScheduledEventUpdateEvent(
      gateway: this,
      oldEvent: client.guilds[guildId].scheduledEvents.cache[event.id],
      event: event,
    );
  }

  GuildScheduledEventDeleteEvent parseGuildScheduledEventDelete(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventDeleteEvent(
      gateway: this,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  GuildScheduledEventUserAddEvent parseGuildScheduledEventUserAdd(Map<String, Object?> raw) {
    return GuildScheduledEventUserAddEvent(
      gateway: this,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  GuildScheduledEventUserRemoveEvent parseGuildScheduledEventUserRemove(Map<String, Object?> raw) {
    return GuildScheduledEventUserRemoveEvent(
      gateway: this,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  IntegrationCreateEvent parseIntegrationCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return IntegrationCreateEvent(
      gateway: this,
      guildId: guildId,
      integration: client.guilds[guildId].integrations.parse(raw),
    );
  }

  IntegrationUpdateEvent parseIntegrationUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final integration = client.guilds[guildId].integrations.parse(raw);

    return IntegrationUpdateEvent(
      gateway: this,
      guildId: guildId,
      oldIntegration: client.guilds[guildId].integrations.cache[integration.id],
      integration: integration,
    );
  }

  IntegrationDeleteEvent parseIntegrationDelete(Map<String, Object?> raw) {
    return IntegrationDeleteEvent(
      gateway: this,
      id: Snowflake.parse(raw['id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
    );
  }

  InviteCreateEvent parseInviteCreate(Map<String, Object?> raw) {
    return InviteCreateEvent(
      gateway: this,
      invite: client.invites.parseWithMetadata({
        'channel': {'id': raw['channel_id']},
        'guild': {'id': raw['guild_id']},
        ...raw,
      }),
    );
  }

  InviteDeleteEvent parseInviteDelete(Map<String, Object?> raw) {
    return InviteDeleteEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      code: raw['code'] as String,
    );
  }

  MessageCreateEvent parseMessageCreate(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final message = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse(raw['channel_id']!),
    ).parse(raw);

    return MessageCreateEvent(
      gateway: this,
      guildId: guildId,
      member: maybeParse(
        raw['member'],
        (Map<String, Object?> raw) => PartialMember(
          id: message.author.id,
          manager: MemberManager(client.options.memberCacheConfig, client, guildId: guildId!),
        ),
      ),
      mentions: parseMany(raw['mentions'] as List<Object?>, client.users.parse),
      message: message,
    );
  }

  MessageUpdateEvent parseMessageUpdate(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final channelId = Snowflake.parse(raw['channel_id']!);
    final id = Snowflake.parse(raw['id']!);

    return MessageUpdateEvent(
      gateway: this,
      guildId: guildId,
      member: maybeParse(
        raw['member'],
        (Map<String, Object?> raw) => PartialMember(
          id: Snowflake.parse((raw['author'] as Map<String, Object?>)['id']!),
          manager: client.guilds[guildId ?? Snowflake.zero].members,
        ),
      ),
      mentions: parseMany(raw['mentions'] as List<Object?>, client.users.parse),
      message: (client.channels[channelId] as PartialTextChannel).messages[id],
      oldMessage: (client.channels[channelId] as PartialTextChannel).messages.cache[id],
    );
  }

  MessageDeleteEvent parseMessageDelete(Map<String, Object?> raw) {
    return MessageDeleteEvent(
      gateway: this,
      id: Snowflake.parse(raw['id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageBulkDeleteEvent parseMessageBulkDelete(Map<String, Object?> raw) {
    return MessageBulkDeleteEvent(
      gateway: this,
      ids: parseMany(raw['ids'] as List<Object?>, Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageReactionAddEvent parseMessageReactionAdd(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return MessageReactionAddEvent(
      gateway: this,
      userId: Snowflake.parse(raw['user_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: guildId,
      member: maybeParse(raw['member'], client.guilds[guildId ?? Snowflake.zero].members.parse),
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  MessageReactionRemoveEvent parseMessageReactionRemove(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return MessageReactionRemoveEvent(
      gateway: this,
      userId: Snowflake.parse(raw['user_id'] as String),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      messageId: Snowflake.parse(raw['message_id'] as String),
      guildId: guildId,
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  MessageReactionRemoveAllEvent parseMessageReactionRemoveAll(Map<String, Object?> raw) {
    return MessageReactionRemoveAllEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageReactionRemoveEmojiEvent parseMessageReactionRemoveEmoji(Map<String, Object?> raw) {
    return MessageReactionRemoveEmojiEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  PresenceUpdateEvent parsePresenceUpdate(Map<String, Object?> raw) {
    return PresenceUpdateEvent(
      gateway: this,
      user: maybeParse(
        raw['user'],
        (Map<String, Object?> raw) => PartialUser(id: Snowflake.parse(raw['id']!), manager: client.users),
      ),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      status: maybeParse(raw['status'], UserStatus.parse),
      activities: maybeParseMany(raw['activities'], parseActivity),
      clientStatus: maybeParse(raw['client_status'], parseClientStatus),
    );
  }

  TypingStartEvent parseTypingStart(Map<String, Object?> raw) {
    var guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return TypingStartEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: guildId,
      userId: Snowflake.parse(raw['user_id']!),
      timestamp: DateTime.fromMillisecondsSinceEpoch((raw['timestamp'] as int) * Duration.millisecondsPerSecond),
      member: maybeParse(raw['member'], client.guilds[guildId ?? Snowflake.zero].members.parse),
    );
  }

  UserUpdateEvent parseUserUpdate(Map<String, Object?> raw) {
    final user = client.users.parse(raw);

    return UserUpdateEvent(
      gateway: this,
      oldUser: client.users.cache[user.id],
      user: user,
    );
  }

  VoiceStateUpdateEvent parseVoiceStateUpdate(Map<String, Object?> raw) {
    final voiceState = client.voice.parseVoiceState(raw);

    return VoiceStateUpdateEvent(
      gateway: this,
      oldState: client.voice.cache[voiceState.cacheKey],
      state: voiceState,
    );
  }

  VoiceServerUpdateEvent parseVoiceServerUpdate(Map<String, Object?> raw) {
    return VoiceServerUpdateEvent(
      gateway: this,
      token: raw['token'] as String,
      guildId: Snowflake.parse(raw['guild_id']!),
      endpoint: raw['endpoint'] as String?,
    );
  }

  WebhooksUpdateEvent parseWebhooksUpdate(Map<String, Object?> raw) {
    return WebhooksUpdateEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
    );
  }

  InteractionCreateEvent parseInteractionCreate(Map<String, Object?> raw) {
    return InteractionCreateEvent(
      gateway: this,
    );
  }

  StageInstanceCreateEvent parseStageInstanceCreate(Map<String, Object?> raw) {
    return StageInstanceCreateEvent(
      gateway: this,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  StageInstanceUpdateEvent parseStageInstanceUpdate(Map<String, Object?> raw) {
    final instance = client.channels.parseStageInstance(raw);

    return StageInstanceUpdateEvent(
      gateway: this,
      oldInstance: client.channels.stageInstanceCache[instance.channelId],
      instance: instance,
    );
  }

  StageInstanceDeleteEvent parseStageInstanceDelete(Map<String, Object?> raw) {
    return StageInstanceDeleteEvent(
      gateway: this,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  /// Stream all members in a guild that match [query] or [userIds].
  ///
  /// If neither is provided, all members in the guild are returned.
  Stream<Member> listGuildMembers(
    Snowflake guildId, {
    String? query,
    int? limit,
    List<Snowflake>? userIds,
    bool? includePresences,
    String? nonce,
  }) async* {
    if (userIds == null) {
      query ??= '';
    }

    limit ??= 0;
    nonce ??= '${Snowflake.now().value.toRadixString(36)}${guildId.value.toRadixString(36)}';

    final shard = shardFor(guildId);
    shard.add(Send(opcode: Opcode.requestGuildMembers, data: {
      'guild_id': guildId.toString(),
      if (query != null) 'query': query,
      'limit': limit,
      if (includePresences != null) 'presences': includePresences,
      if (userIds != null) 'user_ids': userIds.map((e) => e.toString()).toList(),
      'nonce': nonce,
    }));

    int chunksReceived = 0;

    await for (final event in events) {
      if (event is! GuildMembersChunkEvent || event.nonce != nonce) {
        continue;
      }

      yield* Stream.fromIterable(event.members);

      chunksReceived++;
      if (chunksReceived == event.chunkCount) {
        break;
      }
    }
  }

  /// Update the client's voice state in the guild with ID [guildId].
  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) => shardFor(guildId).updateVoiceState(guildId, builder);

  /// Update the client's presence on all shards.
  void updatePresence(PresenceBuilder builder) {
    for (final shard in shards) {
      shard.add(Send(opcode: Opcode.presenceUpdate, data: builder.build()));
    }
  }
}
