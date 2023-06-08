import 'dart:async';

import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/gateway/event_parser.dart';
import 'package:nyxx/src/gateway/message.dart';
import 'package:nyxx/src/gateway/shard.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
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
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// Handles the connection to Discord's Gateway with shards, manages the client's cache based on Gateway events and provides an interface to the Gateway.
// TODO: Handle ErrorReceived events
// TODO: Potentially withold events until we have a listener?
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
        _messagesController.add,
        onError: _messagesController.addError,
        onDone: () async {
          if (_closing) {
            return;
          }

          // Shard went down
          // TODO: Throw an error

          await close();
        },
      );
    }

    // TODO: Add ThreadMember cache for ThreadListSyncEvent, ThreadMemberUpdateEvent, ThreadMembersUpdateEvent
    // TODO: GuildBanAddEvent and GuildBanRemoveEvent need to update cache
    // TODO: GuildEmojisUpdateEvent, GuildStickersUpdateEvent, GuildScheduledEventCreateEvent, GuildScheduledEventUpdateEvent, GuildScheduledEventDeleteEvent,
    // GuildScheduledEventUserAddEvent, GuildScheduledEventUserRemoveEvent, IntegrationCreateEvent, IntegrationUpdateEvent, IntegrationDeleteEvent,
    // InviteCreateEvent, InviteDeleteEvent, MessageReactionAddEvent, MessageReactionRemoveEvent, MessageReactionRemoveAllEvent,MessageReactionRemoveEmojiEvent,
    // PresenceUpdateEvent, VoiceStateUpdateEvent, StageInstanceCreateEvent, StageInstanceUpdateEvent, StageInstanceDeleteEvent,
    // ApplicationCommandPermissionsUpdateEvent, AutoModerationRuleCreateEvent, AutoModerationRuleUpdateEvent, AutoModerationRuleDeleteEvent,
    // AutoModerationActionExecutionEvent

    // Handle all events which should update cache.
    events.listen((event) => switch (event) {
          ReadyEvent(:final user) => client.users.cache[user.id] = user,
          ChannelCreateEvent(:final channel) || ChannelUpdateEvent(:final channel) => client.channels.cache[channel.id] = channel,
          ChannelDeleteEvent(:final channel) => client.channels.cache.remove(channel.id),
          ThreadCreateEvent(:final thread) || ThreadUpdateEvent(:final thread) => client.channels.cache[thread.id] = thread,
          ThreadDeleteEvent(:final thread) => client.channels.cache.remove(thread.id),
          ThreadListSyncEvent(:final threads) => client.channels.cache.addEntries(threads.map((thread) => MapEntry(thread.id, thread))),
          final GuildCreateEvent event => () {
              client.guilds.cache[event.guild.id] = event.guild;

              event.guild.members.cache.addEntries(event.members.map((member) => MapEntry(member.id, member)));
              client.channels.cache.addEntries(event.channels.map((channel) => MapEntry(channel.id, channel)));
              client.channels.cache.addEntries(event.threads.map((thread) => MapEntry(thread.id, thread)));
              // TODO: stageInstances, scheduledEvents
            }(),
          GuildUpdateEvent(:final guild) => client.guilds.cache[guild.id] = guild,
          // TODO: Do we want to remove guilds from the cache when they are only unavailable?
          GuildDeleteEvent(:final guild, isUnavailable: false) => client.guilds.cache.remove(guild.id),
          GuildMemberAddEvent(:final guildId, :final member) ||
          GuildMemberUpdateEvent(:final guildId, :final member) =>
            client.guilds[guildId].members.cache[member.id] = member,
          GuildMemberRemoveEvent(:final guildId, :final user) => client.guilds[guildId].members.cache.remove(user.id),
          GuildMembersChunkEvent(:final guildId, :final members) =>
            client.guilds[guildId].members.cache.addEntries(members.map((member) => MapEntry(member.id, member))),
          GuildRoleCreateEvent(:final guildId, :final role) ||
          GuildRoleUpdateEvent(:final guildId, :final role) =>
            client.guilds[guildId].roles.cache[role.id] = role,
          GuildRoleDeleteEvent(:final guildId, :final roleId) => client.guilds[guildId].roles.cache.remove(roleId),
          MessageCreateEvent(:final message) ||
          MessageUpdateEvent(:final message) =>
            MessageManager(client.options.messageCacheConfig, client, channelId: message.channelId).cache[message.id] = message,
          MessageDeleteEvent(id: final messageId, :final channelId) =>
            MessageManager(client.options.messageCacheConfig, client, channelId: channelId).cache.remove(messageId),
          MessageBulkDeleteEvent(ids: final messageIds, :final channelId) =>
            // ignore: avoid_function_literals_in_foreach_calls
            messageIds.forEach((messageId) => MessageManager(client.options.messageCacheConfig, client, channelId: channelId).cache.remove(messageId)),
          UserUpdateEvent(:final user) => client.users.cache[user.id] = user,
          _ => null,
        });
  }

  /// Connect to the gateway using the provided [client] and [gatewayBot] configuration.
  static Future<Gateway> connect(NyxxGateway client, GatewayBot gatewayBot) async {
    final totalShards = client.apiOptions.totalShards ?? gatewayBot.shards;
    final List<int> shardIds = client.apiOptions.shards ?? List.generate(totalShards, (i) => i);

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
        () => Shard.connect(id, totalShards, client.apiOptions, gatewayBot.url),
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

    return mapping[raw.name]?.call(raw.payload) ?? UnknownDispatchEvent(raw: raw);
  }

  ReadyEvent parseReady(Map<String, Object?> raw) {
    return ReadyEvent(
      version: raw['v'] as int,
      user: client.users.parse(raw['user'] as Map<String, Object?>),
      guilds: parseMany(
        raw['guilds'] as List<Object?>,
        (Map<String, Object?> raw) => PartialGuild(id: Snowflake.parse(raw['id'] as String), manager: client.guilds),
      ),
      sessionId: raw['session_id'] as String,
      gatewayResumeUrl: Uri.parse(raw['resume_gateway_url'] as String),
      shardId: (raw['shard'] as List<Object?>?)?[0] as int?,
      totalShards: (raw['shard'] as List<Object?>?)?[1] as int?,
      application: PartialApplication(id: Snowflake.parse((raw['application'] as Map<String, Object?>)['id'] as String)),
    );
  }

  ResumedEvent parseResumed(Map<String, Object?> raw) {
    return ResumedEvent();
  }

  ApplicationCommandPermissionsUpdateEvent parseApplicationCommandPermissionsUpdate(Map<String, Object?> raw) {
    return ApplicationCommandPermissionsUpdateEvent();
  }

  AutoModerationRuleCreateEvent parseAutoModerationRuleCreate(Map<String, Object?> raw) {
    return AutoModerationRuleCreateEvent();
  }

  AutoModerationRuleUpdateEvent parseAutoModerationRuleUpdate(Map<String, Object?> raw) {
    return AutoModerationRuleUpdateEvent();
  }

  AutoModerationRuleDeleteEvent parseAutoModerationRuleDelete(Map<String, Object?> raw) {
    return AutoModerationRuleDeleteEvent();
  }

  AutoModerationActionExecutionEvent parseAutoModerationActionExecution(Map<String, Object?> raw) {
    return AutoModerationActionExecutionEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      ruleId: Snowflake.parse(raw['rule_id'] as String),
      userId: Snowflake.parse(raw['user_id'] as String),
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
      channel: client.channels.parse(raw),
    );
  }

  ChannelUpdateEvent parseChannelUpdate(Map<String, Object?> raw) {
    final channel = client.channels.parse(raw);

    return ChannelUpdateEvent(
      oldChannel: client.channels.cache[channel.id],
      channel: channel,
    );
  }

  ChannelDeleteEvent parseChannelDelete(Map<String, Object?> raw) {
    return ChannelDeleteEvent(
      channel: client.channels.parse(raw),
    );
  }

  ThreadCreateEvent parseThreadCreate(Map<String, Object?> raw) {
    return ThreadCreateEvent(
      thread: client.channels.parse(raw) as Thread,
    );
  }

  ThreadUpdateEvent parseThreadUpdate(Map<String, Object?> raw) {
    final thread = client.channels.parse(raw) as Thread;

    return ThreadUpdateEvent(
      oldThread: client.channels.cache[thread.id] as Thread?,
      thread: thread,
    );
  }

  ThreadDeleteEvent parseThreadDelete(Map<String, Object?> raw) {
    return ThreadDeleteEvent(
      thread: PartialChannel(
        id: Snowflake.parse(raw['id'] as String),
        manager: client.channels,
      ),
    );
  }

  ThreadListSyncEvent parseThreadListSync(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return ThreadListSyncEvent(
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
      member: client.channels.parseThreadMember(raw),
    );
  }

  ThreadMembersUpdateEvent parseThreadMembersUpdate(Map<String, Object?> raw) {
    return ThreadMembersUpdateEvent(
      id: Snowflake.parse(raw['id'] as String),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      memberCount: raw['member_count'] as int,
      addedMembers: maybeParseMany(raw['added_members'], client.channels.parseThreadMember),
      removedMemberIds: maybeParseMany(raw['removed_member_ids'], Snowflake.parse),
    );
  }

  ChannelPinsUpdateEvent parseChannelPinsUpdate(Map<String, Object?> raw) {
    return ChannelPinsUpdateEvent(
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
    );
  }

  UnavailableGuildCreateEvent parseGuildCreate(Map<String, Object?> raw) {
    if (raw['unavailable'] == true) {
      return UnavailableGuildCreateEvent(guild: PartialGuild(id: Snowflake.parse(raw['id'] as String), manager: client.guilds));
    }

    final guild = client.guilds.parse(raw);

    return GuildCreateEvent(
      guild: guild,
      joinedAt: DateTime.parse(raw['joined_at'] as String),
      isLarge: raw['large'] as bool,
      memberCount: raw['member_count'] as int,
      voiceStates: parseMany(raw['voice_states'] as List<Object?>, client.voice.parseVoiceState),
      members: parseMany(raw['members'] as List<Object?>, client.guilds[Snowflake.zero].members.parse),
      channels: parseMany(raw['channels'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as GuildChannel),
      threads: parseMany(raw['threads'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as Thread),
    );
  }

  GuildUpdateEvent parseGuildUpdate(Map<String, Object?> raw) {
    final guild = client.guilds.parse(raw);

    return GuildUpdateEvent(
      oldGuild: client.guilds.cache[guild.id],
      guild: guild,
    );
  }

  GuildDeleteEvent parseGuildDelete(Map<String, Object?> raw) {
    return GuildDeleteEvent(
      guild: PartialGuild(id: Snowflake.parse(raw['id'] as String), manager: client.guilds),
      isUnavailable: raw['unavailable'] as bool,
    );
  }

  GuildBanAddEvent parseGuildBanAdd(Map<String, Object?> raw) {
    return GuildBanAddEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildBanRemoveEvent parseGuildBanRemove(Map<String, Object?> raw) {
    return GuildBanRemoveEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildEmojisUpdateEvent parseGuildEmojisUpdate(Map<String, Object?> raw) {
    return GuildEmojisUpdateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  GuildStickersUpdateEvent parseGuildStickersUpdate(Map<String, Object?> raw) {
    return GuildStickersUpdateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  GuildIntegrationsUpdateEvent parseGuildIntegrationsUpdate(Map<String, Object?> raw) {
    return GuildIntegrationsUpdateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  GuildMemberAddEvent parseGuildMemberAdd(Map<String, Object?> raw) {
    return GuildMemberAddEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      member: client.guilds[Snowflake.zero].members.parse(raw),
    );
  }

  GuildMemberRemoveEvent parseGuildMemberRemove(Map<String, Object?> raw) {
    return GuildMemberRemoveEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  GuildMemberUpdateEvent parseGuildMemberUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);
    // TODO: The member received from the update has mute and deaf as nullable fields, which this parser does not.
    final member = client.guilds[guildId].members.parse(raw);

    return GuildMemberUpdateEvent(
      oldMember: client.guilds[guildId].members.cache[member.id],
      member: member,
      guildId: guildId,
    );
  }

  GuildMembersChunkEvent parseGuildMembersChunk(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return GuildMembersChunkEvent(
      guildId: guildId,
      members: parseMany(raw['members'] as List<Object?>, client.guilds[guildId].members.parse),
      chunkIndex: raw['chunk_index'] as int,
      chunkCount: raw['chunk_count'] as int,
      notFound: maybeParseMany(raw['not_found'], Snowflake.parse),
      nonce: raw['nonce'] as String?,
    );
  }

  GuildRoleCreateEvent parseGuildRoleCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);

    return GuildRoleCreateEvent(
      guildId: guildId,
      role: client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>),
    );
  }

  GuildRoleUpdateEvent parseGuildRoleUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id'] as String);
    final role = client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>);

    return GuildRoleUpdateEvent(
      guildId: guildId,
      oldRole: client.guilds[guildId].roles.cache[role.id],
      role: role,
    );
  }

  GuildRoleDeleteEvent parseGuildRoleDelete(Map<String, Object?> raw) {
    return GuildRoleDeleteEvent(
      roleId: Snowflake.parse(raw['role_id'] as String),
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  GuildScheduledEventCreateEvent parseGuildScheduledEventCreate(Map<String, Object?> raw) {
    return GuildScheduledEventCreateEvent();
  }

  GuildScheduledEventUpdateEvent parseGuildScheduledEventUpdate(Map<String, Object?> raw) {
    return GuildScheduledEventUpdateEvent();
  }

  GuildScheduledEventDeleteEvent parseGuildScheduledEventDelete(Map<String, Object?> raw) {
    return GuildScheduledEventDeleteEvent();
  }

  GuildScheduledEventUserAddEvent parseGuildScheduledEventUserAdd(Map<String, Object?> raw) {
    return GuildScheduledEventUserAddEvent(
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id'] as String),
      userId: Snowflake.parse(raw['user_id'] as String),
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  GuildScheduledEventUserRemoveEvent parseGuildScheduledEventUserRemove(Map<String, Object?> raw) {
    return GuildScheduledEventUserRemoveEvent(
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id'] as String),
      userId: Snowflake.parse(raw['user_id'] as String),
      guildId: Snowflake.parse(raw['guild_id'] as String),
    );
  }

  IntegrationCreateEvent parseIntegrationCreate(Map<String, Object?> raw) {
    return IntegrationCreateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      integration: client.guilds.parseIntegration(raw),
    );
  }

  IntegrationUpdateEvent parseIntegrationUpdate(Map<String, Object?> raw) {
    return IntegrationUpdateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      integration: client.guilds.parseIntegration(raw),
    );
  }

  IntegrationDeleteEvent parseIntegrationDelete(Map<String, Object?> raw) {
    return IntegrationDeleteEvent(
      id: Snowflake.parse(raw['id'] as String),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
    );
  }

  InviteCreateEvent parseInviteCreate(Map<String, Object?> raw) {
    return InviteCreateEvent();
  }

  InviteDeleteEvent parseInviteDelete(Map<String, Object?> raw) {
    return InviteDeleteEvent(
      channelId: Snowflake.parse(raw['channel_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      code: raw['code'] as String,
    );
  }

  MessageCreateEvent parseMessageCreate(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final message = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse(raw['channel_id'] as String),
    ).parse(raw);

    return MessageCreateEvent(
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
    final manager = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse(raw['channel_id'] as String),
    );
    final message = manager.parse(raw);

    return MessageUpdateEvent(
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
      oldMessage: manager.cache[message.id],
    );
  }

  MessageDeleteEvent parseMessageDelete(Map<String, Object?> raw) {
    return MessageDeleteEvent(
      id: Snowflake.parse(raw['id'] as String),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageBulkDeleteEvent parseMessageBulkDelete(Map<String, Object?> raw) {
    return MessageBulkDeleteEvent(
      ids: parseMany(raw['ids'] as List<Object?>, Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageReactionAddEvent parseMessageReactionAdd(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return MessageReactionAddEvent(
      userId: Snowflake.parse(raw['user_id'] as String),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      messageId: Snowflake.parse(raw['message_id'] as String),
      guildId: guildId,
      member: maybeParse(raw['member'], client.guilds[guildId ?? Snowflake.zero].members.parse),
    );
  }

  MessageReactionRemoveEvent parseMessageReactionRemove(Map<String, Object?> raw) {
    return MessageReactionRemoveEvent(
      userId: Snowflake.parse(raw['user_id'] as String),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      messageId: Snowflake.parse(raw['message_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageReactionRemoveAllEvent parseMessageReactionRemoveAll(Map<String, Object?> raw) {
    return MessageReactionRemoveAllEvent(
      channelId: Snowflake.parse(raw['channel_id'] as String),
      messageId: Snowflake.parse(raw['message_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  MessageReactionRemoveEmojiEvent parseMessageReactionRemoveEmoji(Map<String, Object?> raw) {
    return MessageReactionRemoveEmojiEvent(
      channelId: Snowflake.parse(raw['channel_id'] as String),
      messageId: Snowflake.parse(raw['message_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  PresenceUpdateEvent parsePresenceUpdate(Map<String, Object?> raw) {
    return PresenceUpdateEvent(
      user: maybeParse(
        raw['user'],
        (Map<String, Object?> raw) => PartialUser(id: Snowflake.parse(raw['id'] as String), manager: client.users),
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
      channelId: Snowflake.parse(raw['channel_id'] as String),
      guildId: guildId,
      userId: Snowflake.parse(raw['user_id'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch((raw['timestamp'] as int) * Duration.millisecondsPerSecond),
      member: maybeParse(raw['member'], client.guilds[guildId ?? Snowflake.zero].members.parse),
    );
  }

  UserUpdateEvent parseUserUpdate(Map<String, Object?> raw) {
    final user = client.users.parse(raw);

    return UserUpdateEvent(
      oldUser: client.users.cache[user.id],
      user: user,
    );
  }

  VoiceStateUpdateEvent parseVoiceStateUpdate(Map<String, Object?> raw) {
    return VoiceStateUpdateEvent(
      state: client.voice.parseVoiceState(raw),
    );
  }

  VoiceServerUpdateEvent parseVoiceServerUpdate(Map<String, Object?> raw) {
    return VoiceServerUpdateEvent(
      token: raw['token'] as String,
      guildId: Snowflake.parse(raw['guild_id'] as String),
      endpoint: raw['endpoint'] as String?,
    );
  }

  WebhooksUpdateEvent parseWebhooksUpdate(Map<String, Object?> raw) {
    return WebhooksUpdateEvent(
      guildId: Snowflake.parse(raw['guild_id'] as String),
      channelId: Snowflake.parse(raw['channel_id'] as String),
    );
  }

  InteractionCreateEvent parseInteractionCreate(Map<String, Object?> raw) {
    return InteractionCreateEvent();
  }

  StageInstanceCreateEvent parseStageInstanceCreate(Map<String, Object?> raw) {
    return StageInstanceCreateEvent();
  }

  StageInstanceUpdateEvent parseStageInstanceUpdate(Map<String, Object?> raw) {
    return StageInstanceUpdateEvent();
  }

  StageInstanceDeleteEvent parseStageInstanceDelete(Map<String, Object?> raw) {
    return StageInstanceDeleteEvent();
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

    nonce ??= '${Snowflake.now()}$guildId';

    final shard = shardFor(guildId);
    shard.add(Send(opcode: Opcode.requestGuildMembers, data: {
      'guild_id': guildId.toString(),
      if (query != null) 'query': query,
      if (limit != null) 'limit': limit,
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
