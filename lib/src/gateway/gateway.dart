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
import 'package:nyxx/src/models/gateway/events/entitlement.dart';
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
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
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
  // Adapting _messagesController.stream to a broadcast stream instead of
  // simply making _messagesController a broadcast controller means events will
  // be buffered until this field is initialized, which prevents events from
  // being dropped during the connection process.
  late final Stream<ShardMessage> messages = _messagesController.stream.asBroadcastStream();

  final StreamController<ShardMessage> _messagesController = StreamController();

  /// A stream of dispatch events received from all shards.
  // Make this late instead of a getter so only a single subscription is made, which prevents events from being parsed multiple times.
  late final Stream<DispatchEvent> events = messages.transform(StreamTransformer.fromBind((messages) async* {
    await for (final message in messages) {
      if (message is! EventReceived) continue;

      final event = message.event;
      if (event is! RawDispatchEvent) continue;

      final parsedEvent = parseDispatchEvent(event);
      // Update the cache as needed.
      client.updateCacheWith(parsedEvent);
      yield parsedEvent;
    }
  })).asBroadcastStream();

  bool _closing = false;

  /// The average latency across all shards in this [Gateway].
  ///
  /// See [Shard.latency] for details on how the latency is calculated.
  Duration get latency => shards.fold(Duration.zero, (previousValue, element) => previousValue + (element.latency ~/ shards.length));

  final List<Timer> _startTimers = [];

  /// Create a new [Gateway].
  Gateway(this.client, this.gatewayBot, this.shards, this.totalShards, this.shardIds) : super.create() {
    final logger = Logger('${client.options.loggerName}.Gateway');

    // https://discord.com/developers/docs/topics/gateway#rate-limiting
    const identifyDelay = Duration(seconds: 5);
    final maxConcurrency = gatewayBot.sessionStartLimit.maxConcurrency;
    var remainingIdentifyRequests = gatewayBot.sessionStartLimit.remaining;

    // A mapping of rateLimitId (shard.id % maxConcurrency) to Futures that complete when the identify lock for that rate_limit_key is no longer used.
    final identifyLocks = <int, Future<void>>{};

    // Handle messages from the shards and start them according to their rate limit key.
    for (final shard in shards) {
      final rateLimitKey = shard.id % maxConcurrency;

      // Delay the shard starting until it is (approximately) also ready to identify.
      _startTimers.add(Timer(identifyDelay * (shard.id ~/ maxConcurrency), () {
        logger.fine('Starting shard ${shard.id}');
        shard.add(StartShard());
      }));

      shard.listen(
        (event) {
          _messagesController.add(event);

          if (event is RequestingIdentify) {
            final currentLock = identifyLocks[rateLimitKey] ?? Future.value();
            identifyLocks[rateLimitKey] = currentLock.then((_) async {
              if (_closing) return;

              if (remainingIdentifyRequests < client.options.minimumSessionStarts * 5) {
                logger.warning('$remainingIdentifyRequests session starts remaining');
              }

              if (remainingIdentifyRequests < client.options.minimumSessionStarts) {
                await client.close();
                throw OutOfRemainingSessionsError(gatewayBot);
              }

              remainingIdentifyRequests--;
              shard.add(Identify());
              return await Future.delayed(identifyDelay);
            });
          }
        },
        onError: _messagesController.addError,
        onDone: () async {
          if (_closing) {
            return;
          }

          await client.close();

          throw ShardDisconnectedError(shard);
        },
        cancelOnError: false,
      );
    }
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

    final shards = shardIds.map((id) => Shard.connect(id, totalShards, client.apiOptions, gatewayBot.url, client));
    return Gateway(client, gatewayBot, await Future.wait(shards), totalShards, shardIds);
  }

  /// Close this [Gateway] instance, disconnecting all shards and closing the event streams.
  Future<void> close() async {
    _closing = true;
    // Make sure we don't start any shards after we have closed.
    for (final timer in _startTimers) {
      timer.cancel();
    }
    await Future.wait(shards.map((shard) => shard.close()));
    _messagesController.close();
  }

  /// Compute the ID of the shard that handles events for [guildId].
  int shardIdFor(Snowflake guildId) => (guildId.value >> 22) % totalShards;

  /// Return the shard that handles events for [guildId].
  ///
  /// Throws an error if the shard handling events for [guildId] is not in this [Gateway] instance.
  Shard shardFor(Snowflake guildId) => shards.singleWhere((shard) => shard.id == shardIdFor(guildId));

  /// Parse a [DispatchEvent] from [raw].
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
      'ENTITLEMENT_CREATE': parseEntitlementCreate,
      'ENTITLEMENT_UPDATE': parseEntitlementUpdate,
      'ENTITLEMENT_DELETE': parseEntitlementDelete,
    };

    return mapping[raw.name]?.call(raw.payload) ?? UnknownDispatchEvent(gateway: this, raw: raw);
  }

  /// Parse a [ReadyEvent] from [raw].
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

  /// Parse a [ResumedEvent] from [raw].
  ResumedEvent parseResumed(Map<String, Object?> raw) {
    return ResumedEvent(
      gateway: this,
    );
  }

  /// Parse an [ApplicationCommandPermissionsUpdateEvent] from [raw].
  ApplicationCommandPermissionsUpdateEvent parseApplicationCommandPermissionsUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final permissions = client.guilds[guildId].commands.parseCommandPermissions(raw);

    return ApplicationCommandPermissionsUpdateEvent(
      gateway: this,
      permissions: permissions,
      oldPermissions: client.guilds[guildId].commands.permissionsCache[permissions.id],
    );
  }

  /// Parse an [AutoModerationRuleCreateEvent] from [raw].
  AutoModerationRuleCreateEvent parseAutoModerationRuleCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleCreateEvent(
      gateway: this,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  /// Parse an [AutoModerationRuleUpdateEvent] from [raw].
  AutoModerationRuleUpdateEvent parseAutoModerationRuleUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final rule = client.guilds[guildId].autoModerationRules.parse(raw);

    return AutoModerationRuleUpdateEvent(
      gateway: this,
      oldRule: client.guilds[guildId].autoModerationRules.cache[rule.id],
      rule: rule,
    );
  }

  /// Parse an [AutoModerationRuleDeleteEvent] from [raw].
  AutoModerationRuleDeleteEvent parseAutoModerationRuleDelete(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleDeleteEvent(
      gateway: this,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  /// Parse an [AutoModerationActionExecutionEvent] from [raw].
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

  /// Parse a [ChannelCreateEvent] from [raw].
  ChannelCreateEvent parseChannelCreate(Map<String, Object?> raw) {
    return ChannelCreateEvent(
      gateway: this,
      channel: client.channels.parse(raw),
    );
  }

  /// Parse a [ChannelUpdateEvent] from [raw].
  ChannelUpdateEvent parseChannelUpdate(Map<String, Object?> raw) {
    final channel = client.channels.parse(raw);

    return ChannelUpdateEvent(
      gateway: this,
      oldChannel: client.channels.cache[channel.id],
      channel: channel,
    );
  }

  /// Parse a [ChannelDeleteEvent] from [raw].
  ChannelDeleteEvent parseChannelDelete(Map<String, Object?> raw) {
    return ChannelDeleteEvent(
      gateway: this,
      channel: client.channels.parse(raw),
    );
  }

  /// Parse a [ThreadCreateEvent] from [raw].
  ThreadCreateEvent parseThreadCreate(Map<String, Object?> raw) {
    return ThreadCreateEvent(
      gateway: this,
      thread: client.channels.parse(raw) as Thread,
    );
  }

  /// Parse a [ThreadUpdateEvent] from [raw].
  ThreadUpdateEvent parseThreadUpdate(Map<String, Object?> raw) {
    final thread = client.channels.parse(raw) as Thread;

    return ThreadUpdateEvent(
      gateway: this,
      oldThread: client.channels.cache[thread.id] as Thread?,
      thread: thread,
    );
  }

  /// Parse a [ThreadDeleteEvent] from [raw].
  ThreadDeleteEvent parseThreadDelete(Map<String, Object?> raw) {
    final thread = PartialChannel(
      id: Snowflake.parse(raw['id']!),
      manager: client.channels,
    );

    return ThreadDeleteEvent(
      gateway: this,
      thread: thread,
      deletedThread: client.channels.cache[thread.id] as Thread?,
    );
  }

  /// Parse a [ThreadListSyncEvent] from [raw].
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
      members: parseMany(raw['members'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parseThreadMember(raw, guildId: guildId)),
    );
  }

  /// Parse a [ThreadMemberUpdateEvent] from [raw].
  ThreadMemberUpdateEvent parseThreadMemberUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadMemberUpdateEvent(
      gateway: this,
      member: client.channels.parseThreadMember(raw, guildId: guildId),
      guildId: guildId,
    );
  }

  /// Parse a [ThreadMembersUpdateEvent] from [raw].
  ThreadMembersUpdateEvent parseThreadMembersUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadMembersUpdateEvent(
      gateway: this,
      id: Snowflake.parse(raw['id']!),
      guildId: guildId,
      memberCount: raw['member_count'] as int,
      addedMembers: maybeParseMany(raw['added_members'], (Map<String, Object?> raw) => client.channels.parseThreadMember(raw, guildId: guildId)),
      removedMemberIds: maybeParseMany(raw['removed_member_ids'], Snowflake.parse),
    );
  }

  /// Parse a [ChannelPinsUpdateEvent] from [raw].
  ChannelPinsUpdateEvent parseChannelPinsUpdate(Map<String, Object?> raw) {
    return ChannelPinsUpdateEvent(
      gateway: this,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id']!),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
    );
  }

  /// Parse an [UnavailableGuildCreateEvent] from [raw].
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
      voiceStates: parseMany(
        raw['voice_states'] as List<Object?>,
        (Map<String, Object?> raw) => client.voice.parseVoiceState(raw, guildId: guild.id),
      ),
      members: parseMany(raw['members'] as List<Object?>, client.guilds[guild.id].members.parse),
      channels: parseMany(raw['channels'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as GuildChannel),
      threads: parseMany(raw['threads'] as List<Object?>, (Map<String, Object?> raw) => client.channels.parse(raw, guildId: guild.id) as Thread),
      presences: parseMany(raw['presences'] as List<Object?>, parsePresenceUpdate),
      stageInstances: parseMany(raw['stage_instances'] as List<Object?>, client.channels.parseStageInstance),
      scheduledEvents: parseMany(raw['guild_scheduled_events'] as List<Object?>, client.guilds[guild.id].scheduledEvents.parse),
    );
  }

  /// Parse a [GuildUpdateEvent] from [raw].
  GuildUpdateEvent parseGuildUpdate(Map<String, Object?> raw) {
    final guild = client.guilds.parse(raw);

    return GuildUpdateEvent(
      gateway: this,
      oldGuild: client.guilds.cache[guild.id],
      guild: guild,
    );
  }

  /// Parse a [GuildDeleteEvent] from [raw].
  GuildDeleteEvent parseGuildDelete(Map<String, Object?> raw) {
    final id = Snowflake.parse(raw['id']!);

    return GuildDeleteEvent(
      gateway: this,
      guild: PartialGuild(id: id, manager: client.guilds),
      isUnavailable: raw['unavailable'] as bool? ?? false,
      deletedGuild: client.guilds.cache[id],
      wasRemoved: !raw.containsKey('unavailable'),
    );
  }

  /// Parse a [GuildAuditLogCreateEvent] from [raw].
  GuildAuditLogCreateEvent parseGuildAuditLogCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildAuditLogCreateEvent(
      gateway: this,
      entry: client.guilds[guildId].auditLogs.parse(raw),
      guildId: guildId,
    );
  }

  /// Parse a [GuildBanAddEvent] from [raw].
  GuildBanAddEvent parseGuildBanAdd(Map<String, Object?> raw) {
    return GuildBanAddEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildBanRemoveEvent] from [raw].
  GuildBanRemoveEvent parseGuildBanRemove(Map<String, Object?> raw) {
    return GuildBanRemoveEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildEmojisUpdateEvent] from [raw].
  GuildEmojisUpdateEvent parseGuildEmojisUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildEmojisUpdateEvent(
      gateway: this,
      guildId: guildId,
      emojis: parseMany(raw['emojis'] as List<Object?>, client.guilds[guildId].emojis.parse),
    );
  }

  /// Parse a [GuildStickersUpdateEvent] from [raw].
  GuildStickersUpdateEvent parseGuildStickersUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildStickersUpdateEvent(
      gateway: this,
      guildId: guildId,
      stickers: parseMany(raw['stickers'] as List, client.guilds[guildId].stickers.parse),
    );
  }

  /// Parse a [GuildIntegrationsUpdateEvent] from [raw].
  GuildIntegrationsUpdateEvent parseGuildIntegrationsUpdate(Map<String, Object?> raw) {
    return GuildIntegrationsUpdateEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse a [GuildMemberAddEvent] from [raw].
  GuildMemberAddEvent parseGuildMemberAdd(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildMemberAddEvent(
      gateway: this,
      guildId: guildId,
      member: client.guilds[guildId].members.parse(raw),
    );
  }

  /// Parse a [GuildMemberRemoveEvent] from [raw].
  GuildMemberRemoveEvent parseGuildMemberRemove(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final user = client.users.parse(raw['user'] as Map<String, Object?>);

    return GuildMemberRemoveEvent(
      gateway: this,
      guildId: guildId,
      user: user,
      removedMember: client.guilds[guildId].members.cache[user.id],
    );
  }

  /// Parse a [GuildMemberUpdateEvent] from [raw].
  GuildMemberUpdateEvent parseGuildMemberUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final member = client.guilds[guildId].members.parse(raw);

    return GuildMemberUpdateEvent(
      gateway: this,
      oldMember: client.guilds[guildId].members.cache[member.id],
      member: member,
      guildId: guildId,
    );
  }

  /// Parse a [GuildMembersChunkEvent] from [raw].
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

  /// Parse a [GuildRoleCreateEvent] from [raw].
  GuildRoleCreateEvent parseGuildRoleCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildRoleCreateEvent(
      gateway: this,
      guildId: guildId,
      role: client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildRoleUpdateEvent] from [raw].
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

  /// Parse a [GuildRoleDeleteEvent] from [raw].
  GuildRoleDeleteEvent parseGuildRoleDelete(Map<String, Object?> raw) {
    final roleId = Snowflake.parse(raw['role_id']!);
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildRoleDeleteEvent(
      gateway: this,
      roleId: roleId,
      guildId: guildId,
      deletedRole: client.guilds[guildId].roles.cache[roleId],
    );
  }

  /// Parse a [GuildScheduledEventCreateEvent] from [raw].
  GuildScheduledEventCreateEvent parseGuildScheduledEventCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventCreateEvent(
      gateway: this,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  /// Parse a [GuildScheduledEventUpdateEvent] from [raw].
  GuildScheduledEventUpdateEvent parseGuildScheduledEventUpdate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final event = client.guilds[guildId].scheduledEvents.parse(raw);

    return GuildScheduledEventUpdateEvent(
      gateway: this,
      oldEvent: client.guilds[guildId].scheduledEvents.cache[event.id],
      event: event,
    );
  }

  /// Parse a [GuildScheduledEventDeleteEvent] from [raw].
  GuildScheduledEventDeleteEvent parseGuildScheduledEventDelete(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventDeleteEvent(
      gateway: this,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  /// Parse a [GuildScheduledEventUserAddEvent] from [raw].
  GuildScheduledEventUserAddEvent parseGuildScheduledEventUserAdd(Map<String, Object?> raw) {
    return GuildScheduledEventUserAddEvent(
      gateway: this,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse a [GuildScheduledEventUserRemoveEvent] from [raw].
  GuildScheduledEventUserRemoveEvent parseGuildScheduledEventUserRemove(Map<String, Object?> raw) {
    return GuildScheduledEventUserRemoveEvent(
      gateway: this,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse an [IntegrationCreateEvent] from [raw].
  IntegrationCreateEvent parseIntegrationCreate(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return IntegrationCreateEvent(
      gateway: this,
      guildId: guildId,
      integration: client.guilds[guildId].integrations.parse(raw),
    );
  }

  /// Parse an [IntegrationUpdateEvent] from [raw].
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

  /// Parse an [IntegrationDeleteEvent] from [raw].
  IntegrationDeleteEvent parseIntegrationDelete(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final id = Snowflake.parse(raw['id']!);

    return IntegrationDeleteEvent(
      gateway: this,
      id: id,
      guildId: guildId,
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      deletedIntegration: client.guilds[guildId].integrations.cache[id],
    );
  }

  /// Parse an [InviteCreateEvent] from [raw].
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

  /// Parse an [InviteDeleteEvent] from [raw].
  InviteDeleteEvent parseInviteDelete(Map<String, Object?> raw) {
    return InviteDeleteEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      code: raw['code'] as String,
    );
  }

  /// Parse a [MessageCreateEvent] from [raw].
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

  /// Parse a [MessageUpdateEvent] from [raw].
  MessageUpdateEvent parseMessageUpdate(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final channelId = Snowflake.parse(raw['channel_id']!);
    final id = Snowflake.parse(raw['id']!);

    return MessageUpdateEvent(
      gateway: this,
      guildId: guildId,
      member: maybeParse(
        raw['member'],
        (Map<String, Object?> _) => PartialMember(
          id: Snowflake.parse((raw['author'] as Map<String, Object?>)['id']!),
          manager: client.guilds[guildId!].members,
        ),
      ),
      mentions: maybeParseMany(raw['mentions'], client.users.parse),
      message: (client.channels[channelId] as PartialTextChannel).messages[id],
      oldMessage: (client.channels[channelId] as PartialTextChannel).messages.cache[id],
    );
  }

  /// Parse a [MessageDeleteEvent] from [raw].
  MessageDeleteEvent parseMessageDelete(Map<String, Object?> raw) {
    final id = Snowflake.parse(raw['id']!);
    final channelId = Snowflake.parse(raw['channel_id']!);

    return MessageDeleteEvent(
      gateway: this,
      id: id,
      channelId: channelId,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      deletedMessage: (client.channels[channelId] as PartialTextChannel).messages.cache[id],
    );
  }

  /// Parse a [MessageBulkDeleteEvent] from [raw].
  MessageBulkDeleteEvent parseMessageBulkDelete(Map<String, Object?> raw) {
    final ids = parseMany(raw['ids'] as List<Object?>, Snowflake.parse);
    final channelId = Snowflake.parse(raw['channel_id']!);

    return MessageBulkDeleteEvent(
      gateway: this,
      ids: ids,
      deletedMessages: ids.map((id) => (client.channels[channelId] as PartialTextChannel).messages.cache[id]).nonNulls.toList(),
      channelId: channelId,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  /// Parse a [MessageReactionAddEvent] from [raw].
  MessageReactionAddEvent parseMessageReactionAdd(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final userId = Snowflake.parse(raw['user_id']!);

    return MessageReactionAddEvent(
      gateway: this,
      userId: userId,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: guildId,
      // Don't use a tearoff so we don't evaluate `guildId!` unless member is set.
      member: maybeParse(raw['member'], (Map<String, Object?> raw) => client.guilds[guildId!].members.parse(raw, userId: userId)),
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
      messageAuthorId: maybeParse(raw['message_author_id'], Snowflake.parse),
    );
  }

  /// Parse a [MessageReactionRemoveEvent] from [raw].
  MessageReactionRemoveEvent parseMessageReactionRemove(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return MessageReactionRemoveEvent(
      gateway: this,
      userId: Snowflake.parse(raw['user_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: guildId,
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  /// Parse a [MessageReactionRemoveAllEvent] from [raw].
  MessageReactionRemoveAllEvent parseMessageReactionRemoveAll(Map<String, Object?> raw) {
    return MessageReactionRemoveAllEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  /// Parse a [MessageReactionRemoveEmojiEvent] from [raw].
  MessageReactionRemoveEmojiEvent parseMessageReactionRemoveEmoji(Map<String, Object?> raw) {
    return MessageReactionRemoveEmojiEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  /// Parse a [PresenceUpdateEvent] from [raw].
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

  /// Parse a [TypingStartEvent] from [raw].
  TypingStartEvent parseTypingStart(Map<String, Object?> raw) {
    var guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final userId = Snowflake.parse(raw['user_id']!);

    return TypingStartEvent(
      gateway: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: guildId,
      userId: userId,
      timestamp: DateTime.fromMillisecondsSinceEpoch((raw['timestamp'] as int) * Duration.millisecondsPerSecond),
      // Don't use a tearoff so we don't evaluate `guildId!` unless member is set.
      member: maybeParse(raw['member'], (Map<String, Object?> raw) => client.guilds[guildId!].members.parse(raw, userId: userId)),
    );
  }

  /// Parse a [UserUpdateEvent] from [raw].
  UserUpdateEvent parseUserUpdate(Map<String, Object?> raw) {
    final user = client.users.parse(raw);

    return UserUpdateEvent(
      gateway: this,
      oldUser: client.users.cache[user.id],
      user: user,
    );
  }

  /// Parse a [VoiceStateUpdateEvent] from [raw].
  VoiceStateUpdateEvent parseVoiceStateUpdate(Map<String, Object?> raw) {
    final voiceState = client.voice.parseVoiceState(raw);

    return VoiceStateUpdateEvent(
      gateway: this,
      // guildId should never be null in VOICE_STATE_UPDATE.
      oldState: client.guilds[voiceState.guildId!].voiceStates[voiceState.userId],
      state: voiceState,
    );
  }

  /// Parse a [VoiceServerUpdateEvent] from [raw].
  VoiceServerUpdateEvent parseVoiceServerUpdate(Map<String, Object?> raw) {
    return VoiceServerUpdateEvent(
      gateway: this,
      token: raw['token'] as String,
      guildId: Snowflake.parse(raw['guild_id']!),
      endpoint: raw['endpoint'] as String?,
    );
  }

  /// Parse a [WebhooksUpdateEvent] from [raw].
  WebhooksUpdateEvent parseWebhooksUpdate(Map<String, Object?> raw) {
    return WebhooksUpdateEvent(
      gateway: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
    );
  }

  /// Parse an [InteractionCreateEvent] from [raw].
  InteractionCreateEvent<Interaction<dynamic>> parseInteractionCreate(Map<String, Object?> raw) {
    final interaction = client.interactions.parse(raw);

    // Needed to get proper type promotion.
    return switch (interaction.type) {
      InteractionType.ping => InteractionCreateEvent<PingInteraction>(gateway: this, interaction: interaction as PingInteraction),
      InteractionType.applicationCommand =>
        InteractionCreateEvent<ApplicationCommandInteraction>(gateway: this, interaction: interaction as ApplicationCommandInteraction),
      InteractionType.messageComponent =>
        InteractionCreateEvent<MessageComponentInteraction>(gateway: this, interaction: interaction as MessageComponentInteraction),
      InteractionType.modalSubmit => InteractionCreateEvent<ModalSubmitInteraction>(gateway: this, interaction: interaction as ModalSubmitInteraction),
      InteractionType.applicationCommandAutocomplete =>
        InteractionCreateEvent<ApplicationCommandAutocompleteInteraction>(gateway: this, interaction: interaction as ApplicationCommandAutocompleteInteraction),
    } as InteractionCreateEvent<Interaction<dynamic>>;
  }

  /// Parse a [StageInstanceCreateEvent] from [raw].
  StageInstanceCreateEvent parseStageInstanceCreate(Map<String, Object?> raw) {
    return StageInstanceCreateEvent(
      gateway: this,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  /// Parse a [StageInstanceUpdateEvent] from [raw].
  StageInstanceUpdateEvent parseStageInstanceUpdate(Map<String, Object?> raw) {
    final instance = client.channels.parseStageInstance(raw);

    return StageInstanceUpdateEvent(
      gateway: this,
      oldInstance: client.channels.stageInstanceCache[instance.channelId],
      instance: instance,
    );
  }

  /// Parse a [StageInstanceDeleteEvent] from [raw].
  StageInstanceDeleteEvent parseStageInstanceDelete(Map<String, Object?> raw) {
    return StageInstanceDeleteEvent(
      gateway: this,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  /// Parse an [EntitlementCreateEvent] from [raw].
  EntitlementCreateEvent parseEntitlementCreate(Map<String, Object?> raw) {
    final applicationId = Snowflake.parse(raw['application_id']!);

    return EntitlementCreateEvent(
      gateway: this,
      entitlement: client.applications[applicationId].entitlements.parse(raw),
    );
  }

  /// Parse an [EntitlementUpdateEvent] from [raw].
  EntitlementUpdateEvent parseEntitlementUpdate(Map<String, Object?> raw) {
    final applicationId = Snowflake.parse(raw['application_id']!);
    final entitlement = client.applications[applicationId].entitlements.parse(raw);

    return EntitlementUpdateEvent(
      gateway: this,
      entitlement: entitlement,
      oldEntitlement: client.applications[applicationId].entitlements.cache[entitlement.id],
    );
  }

  /// Parse an [EntitlementDeleteEvent] from [raw].
  EntitlementDeleteEvent parseEntitlementDelete(Map<String, Object?> raw) {
    final applicationId = Snowflake.parse(raw['application_id']!);
    final entitlement = client.applications[applicationId].entitlements.parse(raw);

    return EntitlementDeleteEvent(
      gateway: this,
      entitlement: entitlement,
      deletedEntitlement: client.applications[applicationId].entitlements.cache[entitlement.id],
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
