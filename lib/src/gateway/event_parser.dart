import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/events/event.dart';
import 'package:nyxx/src/models/events/ready.dart';
import 'package:nyxx/src/models/events/soundboard.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/events/entitlement.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';
import 'package:nyxx/src/models/events/application_command.dart';
import 'package:nyxx/src/models/events/auto_moderation.dart';
import 'package:nyxx/src/models/events/channel.dart';
import 'package:nyxx/src/models/events/guild.dart';
import 'package:nyxx/src/models/events/integration.dart';
import 'package:nyxx/src/models/events/interaction.dart';
import 'package:nyxx/src/models/events/invite.dart';
import 'package:nyxx/src/models/events/message.dart';
import 'package:nyxx/src/models/events/presence.dart';
import 'package:nyxx/src/models/events/stage_instance.dart';
import 'package:nyxx/src/models/events/voice.dart';
import 'package:nyxx/src/models/events/webhook.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/user/user.dart';

/// An internal class which allows the shard runner to parse gateway events
/// without having a reference to the client's [GatewayManager].
mixin class EventParser {
  Event parseGatewayEvent(Map<String, Object?> raw, {Duration? heartbeatLatency}) {
    final mapping = {
      Opcode.dispatch.value: parseDispatch,
      Opcode.heartbeat.value: parseHeartbeat,
      Opcode.reconnect.value: parseReconnect,
      Opcode.invalidSession.value: parseInvalidSession,
      Opcode.hello.value: parseHello,
      Opcode.heartbeatAck.value: (Map<String, Object?> raw) => parseHeartbeatAck(raw, heartbeatLatency: heartbeatLatency ?? Duration.zero),
    };

    return mapping[raw['op'] as int]!(raw);
  }

  HeartbeatEvent parseHeartbeat(Map<String, Object?> raw) {
    return HeartbeatEvent();
  }

  ReconnectEvent parseReconnect(Map<String, Object?> raw) {
    return ReconnectEvent();
  }

  InvalidSessionEvent parseInvalidSession(Map<String, Object?> raw) {
    return InvalidSessionEvent(
      isResumable: raw['d'] as bool,
    );
  }

  HelloEvent parseHello(Map<String, Object?> raw) {
    return HelloEvent(
      heartbeatInterval: Duration(
        milliseconds: (raw['d'] as Map<String, Object?>)['heartbeat_interval'] as int,
      ),
    );
  }

  HeartbeatAckEvent parseHeartbeatAck(Map<String, Object?> raw, {required Duration heartbeatLatency}) {
    return HeartbeatAckEvent(latency: heartbeatLatency);
  }

  RawDispatchEvent parseDispatch(Map<String, Object?> raw) {
    return RawDispatchEvent(
      seq: raw['s'] as int,
      name: raw['t'] as String,
      payload: raw['d'] as Map<String, Object?>,
    );
  }

  /// Parse a [ReadyEvent] from [raw].
  ReadyEvent parseReady(Map<String, Object?> raw, NyxxRest client) {
    return ReadyEvent(
      client: client,
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
  ResumedEvent parseResumed(Map<String, Object?> raw, NyxxRest client) {
    return ResumedEvent(
      client: client,
    );
  }

  /// Parse an [ApplicationCommandPermissionsUpdateEvent] from [raw].
  ApplicationCommandPermissionsUpdateEvent parseApplicationCommandPermissionsUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final permissions = client.guilds[guildId].commands.parseCommandPermissions(raw);

    return ApplicationCommandPermissionsUpdateEvent(
      client: client,
      permissions: permissions,
      oldPermissions: client.guilds[guildId].commands.permissionsCache[permissions.id],
    );
  }

  /// Parse an [AutoModerationRuleCreateEvent] from [raw].
  AutoModerationRuleCreateEvent parseAutoModerationRuleCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleCreateEvent(
      client: client,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  /// Parse an [AutoModerationRuleUpdateEvent] from [raw].
  AutoModerationRuleUpdateEvent parseAutoModerationRuleUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final rule = client.guilds[guildId].autoModerationRules.parse(raw);

    return AutoModerationRuleUpdateEvent(
      client: client,
      oldRule: client.guilds[guildId].autoModerationRules.cache[rule.id],
      rule: rule,
    );
  }

  /// Parse an [AutoModerationRuleDeleteEvent] from [raw].
  AutoModerationRuleDeleteEvent parseAutoModerationRuleDelete(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationRuleDeleteEvent(
      client: client,
      rule: client.guilds[guildId].autoModerationRules.parse(raw),
    );
  }

  /// Parse an [AutoModerationActionExecutionEvent] from [raw].
  AutoModerationActionExecutionEvent parseAutoModerationActionExecution(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return AutoModerationActionExecutionEvent(
      client: client,
      guildId: guildId,
      action: client.guilds[guildId].autoModerationRules.parseAutoModerationAction(raw['action'] as Map<String, Object?>),
      ruleId: Snowflake.parse(raw['rule_id']!),
      triggerType: TriggerType(raw['rule_trigger_type'] as int),
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
  ChannelCreateEvent parseChannelCreate(Map<String, Object?> raw, NyxxRest client) {
    return ChannelCreateEvent(
      client: client,
      channel: client.channels.parse(raw),
    );
  }

  /// Parse a [ChannelUpdateEvent] from [raw].
  ChannelUpdateEvent parseChannelUpdate(Map<String, Object?> raw, NyxxRest client) {
    final channel = client.channels.parse(raw);

    return ChannelUpdateEvent(
      client: client,
      oldChannel: client.channels.cache[channel.id],
      channel: channel,
    );
  }

  /// Parse a [ChannelDeleteEvent] from [raw].
  ChannelDeleteEvent parseChannelDelete(Map<String, Object?> raw, NyxxRest client) {
    return ChannelDeleteEvent(
      client: client,
      channel: client.channels.parse(raw),
    );
  }

  /// Parse a [ThreadCreateEvent] from [raw].
  ThreadCreateEvent parseThreadCreate(Map<String, Object?> raw, NyxxRest client) {
    return ThreadCreateEvent(
      client: client,
      thread: client.channels.parse(raw) as Thread,
    );
  }

  /// Parse a [ThreadUpdateEvent] from [raw].
  ThreadUpdateEvent parseThreadUpdate(Map<String, Object?> raw, NyxxRest client) {
    final thread = client.channels.parse(raw) as Thread;

    return ThreadUpdateEvent(
      client: client,
      oldThread: client.channels.cache[thread.id] as Thread?,
      thread: thread,
    );
  }

  /// Parse a [ThreadDeleteEvent] from [raw].
  ThreadDeleteEvent parseThreadDelete(Map<String, Object?> raw, NyxxRest client) {
    final thread = PartialChannel(
      id: Snowflake.parse(raw['id']!),
      manager: client.channels,
    );

    return ThreadDeleteEvent(
      client: client,
      thread: thread,
      deletedThread: client.channels.cache[thread.id] as Thread?,
    );
  }

  /// Parse a [ThreadListSyncEvent] from [raw].
  ThreadListSyncEvent parseThreadListSync(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadListSyncEvent(
      client: client,
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
  ThreadMemberUpdateEvent parseThreadMemberUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadMemberUpdateEvent(
      client: client,
      member: client.channels.parseThreadMember(raw, guildId: guildId),
      guildId: guildId,
    );
  }

  /// Parse a [ThreadMembersUpdateEvent] from [raw].
  ThreadMembersUpdateEvent parseThreadMembersUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return ThreadMembersUpdateEvent(
      client: client,
      id: Snowflake.parse(raw['id']!),
      guildId: guildId,
      memberCount: raw['member_count'] as int,
      addedMembers: maybeParseMany(raw['added_members'], (Map<String, Object?> raw) => client.channels.parseThreadMember(raw, guildId: guildId)),
      removedMemberIds: maybeParseMany(raw['removed_member_ids'], Snowflake.parse),
    );
  }

  /// Parse a [ChannelPinsUpdateEvent] from [raw].
  ChannelPinsUpdateEvent parseChannelPinsUpdate(Map<String, Object?> raw, NyxxRest client) {
    return ChannelPinsUpdateEvent(
      client: client,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id']!),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
    );
  }

  /// Parse an [UnavailableGuildCreateEvent] from [raw].
  UnavailableGuildCreateEvent parseGuildCreate(Map<String, Object?> raw, NyxxRest client) {
    if (raw['unavailable'] == true) {
      return UnavailableGuildCreateEvent(client: client, guild: PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds));
    }

    final guild = client.guilds.parse(raw);

    return GuildCreateEvent(
      client: client,
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
      presences: parseMany(raw['presences'] as List<Object?>, (Map<String, Object?> raw) => parsePresenceUpdate(raw, client)),
      stageInstances: parseMany(raw['stage_instances'] as List<Object?>, client.channels.parseStageInstance),
      scheduledEvents: parseMany(raw['guild_scheduled_events'] as List<Object?>, client.guilds[guild.id].scheduledEvents.parse),
    );
  }

  /// Parse a [GuildUpdateEvent] from [raw].
  GuildUpdateEvent parseGuildUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guild = client.guilds.parse(raw);

    return GuildUpdateEvent(
      client: client,
      oldGuild: client.guilds.cache[guild.id],
      guild: guild,
    );
  }

  /// Parse a [GuildDeleteEvent] from [raw].
  GuildDeleteEvent parseGuildDelete(Map<String, Object?> raw, NyxxRest client) {
    final id = Snowflake.parse(raw['id']!);

    return GuildDeleteEvent(
      client: client,
      guild: PartialGuild(id: id, manager: client.guilds),
      isUnavailable: raw['unavailable'] as bool? ?? false,
      deletedGuild: client.guilds.cache[id],
    );
  }

  /// Parse a [GuildAuditLogCreateEvent] from [raw].
  GuildAuditLogCreateEvent parseGuildAuditLogCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildAuditLogCreateEvent(
      client: client,
      entry: client.guilds[guildId].auditLogs.parse(raw),
      guildId: guildId,
    );
  }

  /// Parse a [GuildBanAddEvent] from [raw].
  GuildBanAddEvent parseGuildBanAdd(Map<String, Object?> raw, NyxxRest client) {
    return GuildBanAddEvent(
      client: client,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildBanRemoveEvent] from [raw].
  GuildBanRemoveEvent parseGuildBanRemove(Map<String, Object?> raw, NyxxRest client) {
    return GuildBanRemoveEvent(
      client: client,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildEmojisUpdateEvent] from [raw].
  GuildEmojisUpdateEvent parseGuildEmojisUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildEmojisUpdateEvent(
      client: client,
      guildId: guildId,
      emojis: parseMany(raw['emojis'] as List<Object?>, client.guilds[guildId].emojis.parse),
    );
  }

  /// Parse a [GuildStickersUpdateEvent] from [raw].
  GuildStickersUpdateEvent parseGuildStickersUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildStickersUpdateEvent(
      client: client,
      guildId: guildId,
      stickers: parseMany(raw['stickers'] as List, client.guilds[guildId].stickers.parse),
    );
  }

  /// Parse a [GuildIntegrationsUpdateEvent] from [raw].
  GuildIntegrationsUpdateEvent parseGuildIntegrationsUpdate(Map<String, Object?> raw, NyxxRest client) {
    return GuildIntegrationsUpdateEvent(
      client: client,
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse a [GuildMemberAddEvent] from [raw].
  GuildMemberAddEvent parseGuildMemberAdd(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildMemberAddEvent(
      client: client,
      guildId: guildId,
      member: client.guilds[guildId].members.parse(raw),
    );
  }

  /// Parse a [GuildMemberRemoveEvent] from [raw].
  GuildMemberRemoveEvent parseGuildMemberRemove(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final user = client.users.parse(raw['user'] as Map<String, Object?>);

    return GuildMemberRemoveEvent(
      client: client,
      guildId: guildId,
      user: user,
      removedMember: client.guilds[guildId].members.cache[user.id],
    );
  }

  /// Parse a [GuildMemberUpdateEvent] from [raw].
  GuildMemberUpdateEvent parseGuildMemberUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final member = client.guilds[guildId].members.parse(raw);

    return GuildMemberUpdateEvent(
      client: client,
      oldMember: client.guilds[guildId].members.cache[member.id],
      member: member,
      guildId: guildId,
    );
  }

  /// Parse a [GuildMembersChunkEvent] from [raw].
  GuildMembersChunkEvent parseGuildMembersChunk(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildMembersChunkEvent(
      client: client,
      guildId: guildId,
      members: parseMany(raw['members'] as List<Object?>, client.guilds[guildId].members.parse),
      chunkIndex: raw['chunk_index'] as int,
      chunkCount: raw['chunk_count'] as int,
      notFound: maybeParseMany(raw['not_found'], Snowflake.parse),
      presences: maybeParseMany(raw['presences'], (Map<String, Object?> raw) => parsePresenceUpdate(raw, client)),
      nonce: raw['nonce'] as String?,
    );
  }

  /// Parse a [GuildRoleCreateEvent] from [raw].
  GuildRoleCreateEvent parseGuildRoleCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildRoleCreateEvent(
      client: client,
      guildId: guildId,
      role: client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>),
    );
  }

  /// Parse a [GuildRoleUpdateEvent] from [raw].
  GuildRoleUpdateEvent parseGuildRoleUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final role = client.guilds[guildId].roles.parse(raw['role'] as Map<String, Object?>);

    return GuildRoleUpdateEvent(
      client: client,
      guildId: guildId,
      oldRole: client.guilds[guildId].roles.cache[role.id],
      role: role,
    );
  }

  /// Parse a [GuildRoleDeleteEvent] from [raw].
  GuildRoleDeleteEvent parseGuildRoleDelete(Map<String, Object?> raw, NyxxRest client) {
    final roleId = Snowflake.parse(raw['role_id']!);
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildRoleDeleteEvent(
      client: client,
      roleId: roleId,
      guildId: guildId,
      deletedRole: client.guilds[guildId].roles.cache[roleId],
    );
  }

  /// Parse a [GuildScheduledEventCreateEvent] from [raw].
  GuildScheduledEventCreateEvent parseGuildScheduledEventCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventCreateEvent(
      client: client,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  /// Parse a [GuildScheduledEventUpdateEvent] from [raw].
  GuildScheduledEventUpdateEvent parseGuildScheduledEventUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final event = client.guilds[guildId].scheduledEvents.parse(raw);

    return GuildScheduledEventUpdateEvent(
      client: client,
      oldEvent: client.guilds[guildId].scheduledEvents.cache[event.id],
      event: event,
    );
  }

  /// Parse a [GuildScheduledEventDeleteEvent] from [raw].
  GuildScheduledEventDeleteEvent parseGuildScheduledEventDelete(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return GuildScheduledEventDeleteEvent(
      client: client,
      event: client.guilds[guildId].scheduledEvents.parse(raw),
    );
  }

  /// Parse a [GuildScheduledEventUserAddEvent] from [raw].
  GuildScheduledEventUserAddEvent parseGuildScheduledEventUserAdd(Map<String, Object?> raw, NyxxRest client) {
    return GuildScheduledEventUserAddEvent(
      client: client,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse a [GuildScheduledEventUserRemoveEvent] from [raw].
  GuildScheduledEventUserRemoveEvent parseGuildScheduledEventUserRemove(Map<String, Object?> raw, NyxxRest client) {
    return GuildScheduledEventUserRemoveEvent(
      client: client,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      userId: Snowflake.parse(raw['user_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
    );
  }

  /// Parse an [IntegrationCreateEvent] from [raw].
  IntegrationCreateEvent parseIntegrationCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return IntegrationCreateEvent(
      client: client,
      guildId: guildId,
      integration: client.guilds[guildId].integrations.parse(raw),
    );
  }

  /// Parse an [IntegrationUpdateEvent] from [raw].
  IntegrationUpdateEvent parseIntegrationUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final integration = client.guilds[guildId].integrations.parse(raw);

    return IntegrationUpdateEvent(
      client: client,
      guildId: guildId,
      oldIntegration: client.guilds[guildId].integrations.cache[integration.id],
      integration: integration,
    );
  }

  /// Parse an [IntegrationDeleteEvent] from [raw].
  IntegrationDeleteEvent parseIntegrationDelete(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final id = Snowflake.parse(raw['id']!);

    return IntegrationDeleteEvent(
      client: client,
      id: id,
      guildId: guildId,
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      deletedIntegration: client.guilds[guildId].integrations.cache[id],
    );
  }

  /// Parse an [InviteCreateEvent] from [raw].
  InviteCreateEvent parseInviteCreate(Map<String, Object?> raw, NyxxRest client) {
    return InviteCreateEvent(
      client: client,
      invite: client.invites.parseWithMetadata({
        'channel': {'id': raw['channel_id']},
        'guild': {'id': raw['guild_id']},
        ...raw,
      }),
    );
  }

  /// Parse an [InviteDeleteEvent] from [raw].
  InviteDeleteEvent parseInviteDelete(Map<String, Object?> raw, NyxxRest client) {
    return InviteDeleteEvent(
      client: client,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      code: raw['code'] as String,
    );
  }

  /// Parse a [MessageCreateEvent] from [raw].
  MessageCreateEvent parseMessageCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final message = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse(raw['channel_id']!),
    ).parse(raw);

    return MessageCreateEvent(
      client: client,
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
  MessageUpdateEvent parseMessageUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final channelId = Snowflake.parse(raw['channel_id']!);
    final id = Snowflake.parse(raw['id']!);

    return MessageUpdateEvent(
      client: client,
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
  MessageDeleteEvent parseMessageDelete(Map<String, Object?> raw, NyxxRest client) {
    final id = Snowflake.parse(raw['id']!);
    final channelId = Snowflake.parse(raw['channel_id']!);

    return MessageDeleteEvent(
      client: client,
      id: id,
      channelId: channelId,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      deletedMessage: (client.channels[channelId] as PartialTextChannel).messages.cache[id],
    );
  }

  /// Parse a [MessageBulkDeleteEvent] from [raw].
  MessageBulkDeleteEvent parseMessageBulkDelete(Map<String, Object?> raw, NyxxRest client) {
    final ids = parseMany(raw['ids'] as List<Object?>, Snowflake.parse);
    final channelId = Snowflake.parse(raw['channel_id']!);

    return MessageBulkDeleteEvent(
      client: client,
      ids: ids,
      deletedMessages: ids.map((id) => (client.channels[channelId] as PartialTextChannel).messages.cache[id]).nonNulls.toList(),
      channelId: channelId,
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  /// Parse a [MessageReactionAddEvent] from [raw].
  MessageReactionAddEvent parseMessageReactionAdd(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final userId = Snowflake.parse(raw['user_id']!);

    return MessageReactionAddEvent(
      client: client,
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
  MessageReactionRemoveEvent parseMessageReactionRemove(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return MessageReactionRemoveEvent(
      client: client,
      userId: Snowflake.parse(raw['user_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: guildId,
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  /// Parse a [MessageReactionRemoveAllEvent] from [raw].
  MessageReactionRemoveAllEvent parseMessageReactionRemoveAll(Map<String, Object?> raw, NyxxRest client) {
    return MessageReactionRemoveAllEvent(
      client: client,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  /// Parse a [MessageReactionRemoveEmojiEvent] from [raw].
  MessageReactionRemoveEmojiEvent parseMessageReactionRemoveEmoji(Map<String, Object?> raw, NyxxRest client) {
    return MessageReactionRemoveEmojiEvent(
      client: client,
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
    );
  }

  /// Parse a [PresenceUpdateEvent] from [raw].
  PresenceUpdateEvent parsePresenceUpdate(Map<String, Object?> raw, NyxxRest client) {
    return PresenceUpdateEvent(
      client: client,
      user: maybeParse(
        raw['user'],
        (Map<String, Object?> raw) => PartialUser(id: Snowflake.parse(raw['id']!), manager: client.users),
      ),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      status: maybeParse(raw['status'], UserStatus.new),
      activities: maybeParseMany(raw['activities'], (Map<String, Object?> raw) => parseActivity(raw, client)),
      clientStatus: maybeParse(raw['client_status'], parseClientStatus),
    );
  }

  /// Parse a [TypingStartEvent] from [raw].
  TypingStartEvent parseTypingStart(Map<String, Object?> raw, NyxxRest client) {
    var guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final userId = Snowflake.parse(raw['user_id']!);

    return TypingStartEvent(
      client: client,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: guildId,
      userId: userId,
      timestamp: DateTime.fromMillisecondsSinceEpoch((raw['timestamp'] as int) * Duration.millisecondsPerSecond),
      // Don't use a tearoff so we don't evaluate `guildId!` unless member is set.
      member: maybeParse(raw['member'], (Map<String, Object?> raw) => client.guilds[guildId!].members.parse(raw, userId: userId)),
    );
  }

  /// Parse a [UserUpdateEvent] from [raw].
  UserUpdateEvent parseUserUpdate(Map<String, Object?> raw, NyxxRest client) {
    final user = client.users.parse(raw);

    return UserUpdateEvent(
      client: client,
      oldUser: client.users.cache[user.id],
      user: user,
    );
  }

  /// Parse a [VoiceChannelEffectSendEvent] from [raw].
  VoiceChannelEffectSendEvent parseVoiceChannelEffectSend(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return VoiceChannelEffectSendEvent(
      client: client,
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: guildId,
      userId: Snowflake.parse(raw['user_id']!),
      emoji: maybeParse(raw['emoji'], client.guilds[guildId].emojis.parse),
      animationType: maybeParse(raw['animation_type'], AnimationType.new),
      animationId: raw['animation_id'] as int?,
      soundId: maybeParse(raw['sound_id'], Snowflake.parse),
      soundVolume: raw['sound_volume'] as double?,
    );
  }

  /// Parse a [VoiceStateUpdateEvent] from [raw].
  VoiceStateUpdateEvent parseVoiceStateUpdate(Map<String, Object?> raw, NyxxRest client) {
    final voiceState = client.voice.parseVoiceState(raw);

    return VoiceStateUpdateEvent(
      client: client,
      // guildId should never be null in VOICE_STATE_UPDATE.
      oldState: client.guilds[voiceState.guildId!].voiceStates[voiceState.userId],
      state: voiceState,
    );
  }

  /// Parse a [VoiceServerUpdateEvent] from [raw].
  VoiceServerUpdateEvent parseVoiceServerUpdate(Map<String, Object?> raw, NyxxRest client) {
    return VoiceServerUpdateEvent(
      client: client,
      token: raw['token'] as String,
      guildId: Snowflake.parse(raw['guild_id']!),
      endpoint: raw['endpoint'] as String?,
    );
  }

  /// Parse a [WebhooksUpdateEvent] from [raw].
  WebhooksUpdateEvent parseWebhooksUpdate(Map<String, Object?> raw, NyxxRest client) {
    return WebhooksUpdateEvent(
      client: client,
      guildId: Snowflake.parse(raw['guild_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
    );
  }

  /// Parse an [InteractionCreateEvent] from [raw].
  InteractionCreateEvent<Interaction<dynamic>> parseInteractionCreate(Map<String, Object?> raw, NyxxRest client) {
    final interaction = client.interactions.parse(raw);

    // Needed to get proper type promotion.
    return switch (interaction.type) {
      InteractionType.ping => InteractionCreateEvent<PingInteraction>(client: client, interaction: interaction as PingInteraction),
      InteractionType.applicationCommand =>
        InteractionCreateEvent<ApplicationCommandInteraction>(client: client, interaction: interaction as ApplicationCommandInteraction),
      InteractionType.messageComponent =>
        InteractionCreateEvent<MessageComponentInteraction>(client: client, interaction: interaction as MessageComponentInteraction),
      InteractionType.modalSubmit => InteractionCreateEvent<ModalSubmitInteraction>(client: client, interaction: interaction as ModalSubmitInteraction),
      InteractionType.applicationCommandAutocomplete => InteractionCreateEvent<ApplicationCommandAutocompleteInteraction>(
          client: client, interaction: interaction as ApplicationCommandAutocompleteInteraction),
      InteractionType() => throw StateError('Unknown interaction type: ${interaction.type}'),
    } as InteractionCreateEvent<Interaction<dynamic>>;
  }

  /// Parse a [StageInstanceCreateEvent] from [raw].
  StageInstanceCreateEvent parseStageInstanceCreate(Map<String, Object?> raw, NyxxRest client) {
    return StageInstanceCreateEvent(
      client: client,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  /// Parse a [StageInstanceUpdateEvent] from [raw].
  StageInstanceUpdateEvent parseStageInstanceUpdate(Map<String, Object?> raw, NyxxRest client) {
    final instance = client.channels.parseStageInstance(raw);

    return StageInstanceUpdateEvent(
      client: client,
      oldInstance: client.channels.stageInstanceCache[instance.channelId],
      instance: instance,
    );
  }

  /// Parse a [StageInstanceDeleteEvent] from [raw].
  StageInstanceDeleteEvent parseStageInstanceDelete(Map<String, Object?> raw, NyxxRest client) {
    return StageInstanceDeleteEvent(
      client: client,
      instance: client.channels.parseStageInstance(raw),
    );
  }

  /// Parse an [EntitlementCreateEvent] from [raw].
  EntitlementCreateEvent parseEntitlementCreate(Map<String, Object?> raw, NyxxRest client) {
    final applicationId = Snowflake.parse(raw['application_id']!);

    return EntitlementCreateEvent(
      client: client,
      entitlement: client.applications[applicationId].entitlements.parse(raw),
    );
  }

  /// Parse an [EntitlementUpdateEvent] from [raw].
  EntitlementUpdateEvent parseEntitlementUpdate(Map<String, Object?> raw, NyxxRest client) {
    final applicationId = Snowflake.parse(raw['application_id']!);
    final entitlement = client.applications[applicationId].entitlements.parse(raw);

    return EntitlementUpdateEvent(
      client: client,
      entitlement: entitlement,
      oldEntitlement: client.applications[applicationId].entitlements.cache[entitlement.id],
    );
  }

  /// Parse an [EntitlementDeleteEvent] from [raw].
  EntitlementDeleteEvent parseEntitlementDelete(Map<String, Object?> raw, NyxxRest client) {
    final applicationId = Snowflake.parse(raw['application_id']!);
    final entitlement = client.applications[applicationId].entitlements.parse(raw);

    return EntitlementDeleteEvent(
      client: client,
      entitlement: entitlement,
      deletedEntitlement: client.applications[applicationId].entitlements.cache[entitlement.id],
    );
  }

  /// Parse an [MessagePollVoteAddEvent] from [raw].
  MessagePollVoteAddEvent parseMessagePollVoteAdd(Map<String, Object?> raw, NyxxRest client) {
    return MessagePollVoteAddEvent(
      client: client,
      userId: Snowflake.parse(raw['user_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      answerId: raw['answer_id'] as int,
    );
  }

  /// Parse an [MessagePollVoteRemoveEvent] from [raw].
  MessagePollVoteRemoveEvent parseMessagePollVoteRemove(Map<String, Object?> raw, NyxxRest client) {
    return MessagePollVoteRemoveEvent(
      client: client,
      userId: Snowflake.parse(raw['user_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      messageId: Snowflake.parse(raw['message_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      answerId: raw['answer_id'] as int,
    );
  }

  GatewayConfiguration parseGatewayConfiguration(Map<String, Object?> raw) {
    return GatewayConfiguration(url: Uri.parse(raw['url'] as String));
  }

  GatewayBot parseGatewayBot(Map<String, Object?> raw) {
    return GatewayBot(
      url: Uri.parse(raw['url'] as String),
      shards: raw['shards'] as int,
      sessionStartLimit: parseSessionStartLimit(raw['session_start_limit'] as Map<String, Object?>),
    );
  }

  SessionStartLimit parseSessionStartLimit(Map<String, Object?> raw) {
    return SessionStartLimit(
      total: raw['total'] as int,
      remaining: raw['remaining'] as int,
      resetAfter: Duration(milliseconds: raw['reset_after'] as int),
      maxConcurrency: raw['max_concurrency'] as int,
    );
  }

  Activity parseActivity(Map<String, Object?> raw, NyxxRest client) {
    // No fields are validated server-side. Expect errors.
    return Activity(
      name: raw['name'] as String,
      type: ActivityType(raw['type'] as int),
      url: tryParse(raw['url'], Uri.parse),
      createdAt: tryParse(raw['created_at'], DateTime.fromMillisecondsSinceEpoch),
      timestamps: tryParse(raw['timestamps'], parseActivityTimestamps),
      applicationId: tryParse(raw['application_id'], Snowflake.parse),
      details: tryParse(raw['details']),
      state: tryParse(raw['state']),
      emoji: tryParse(raw['emoji'], client.guilds[Snowflake.zero].emojis.parse),
      party: tryParse(raw['party'], parseActivityParty),
      assets: tryParse(raw['assets'], parseActivityAssets),
      secrets: tryParse(raw['secrets'], parseActivitySecrets),
      isInstance: tryParse(raw['instance']),
      flags: tryParse(raw['flags'], ActivityFlags.new),
      buttons: tryParseMany(raw['buttons'], parseActivityButton),
    );
  }

  ActivityTimestamps parseActivityTimestamps(Map<String, Object?> raw) {
    return ActivityTimestamps(
      start: maybeParse(raw['start'], (int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds)),
      end: maybeParse(raw['end'], (int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds)),
    );
  }

  ActivityParty parseActivityParty(Map<String, Object?> raw) {
    return ActivityParty(
      id: raw['id'] as String?,
      currentSize: (raw['size'] as List<Object?>?)?[0] as int?,
      maxSize: (raw['size'] as List<Object?>?)?[1] as int?,
    );
  }

  ActivityAssets parseActivityAssets(Map<String, Object?> raw) {
    return ActivityAssets(
      largeImage: raw['large_image'] as String?,
      largeText: raw['large_text'] as String?,
      smallImage: raw['small_image'] as String?,
      smallText: raw['small_text'] as String?,
    );
  }

  ActivitySecrets parseActivitySecrets(Map<String, Object?> raw) {
    return ActivitySecrets(
      join: raw['join'] as String?,
      spectate: raw['spectate'] as String?,
      match: raw['match'] as String?,
    );
  }

  ActivityButton parseActivityButton(Map<String, Object?> raw) {
    return ActivityButton(
      label: raw['label'] as String,
      url: Uri.parse(raw['url'] as String),
    );
  }

  ClientStatus parseClientStatus(Map<String, Object?> raw) {
    return ClientStatus(
      desktop: maybeParse(raw['desktop'], UserStatus.new),
      mobile: maybeParse(raw['mobile'], UserStatus.new),
      web: maybeParse(raw['web'], UserStatus.new),
    );
  }

  SoundboardSoundCreateEvent parseSoundboardSoundCreate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return SoundboardSoundCreateEvent(
      client: client,
      sound: client.guilds[guildId ?? Snowflake.zero].soundboard.parse(raw),
    );
  }

  SoundboardSoundUpdateEvent parseSoundboardSoundUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    return SoundboardSoundUpdateEvent(
      client: client,
      oldSound: client.guilds[guildId ?? Snowflake.zero].soundboard.cache[Snowflake.parse(raw['sound_id']!)],
      sound: client.guilds[guildId ?? Snowflake.zero].soundboard.parse(raw),
    );
  }

  SoundboardSoundDeleteEvent parseSoundboardSoundDelete(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);
    final soundId = Snowflake.parse(raw['sound_id']!);

    return SoundboardSoundDeleteEvent(
      client: client,
      sound: client.guilds[guildId].soundboard.cache[soundId],
      guildId: guildId,
      soundId: soundId,
    );
  }

  SoundboardSoundsUpdateEvent parseSoundboardSoundsUpdate(Map<String, Object?> raw, NyxxRest client) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    final sounds = parseMany(raw['sounds'] as List<Object?>, client.guilds[guildId].soundboard.parse);

    final oldSounds = sounds.map((sound) => client.guilds[guildId].soundboard.cache[sound.id]).toList();

    return SoundboardSoundsUpdateEvent(
      client: client,
      guildId: guildId,
      sounds: sounds,
      oldSounds: oldSounds,
    );
  }

  /// Parse a [DispatchEvent] from [raw].
  DispatchEvent parseDispatchEvent(RawDispatchEvent raw, NyxxRest client) {
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
      'VOICE_CHANNEL_EFFECT_SEND': parseVoiceChannelEffectSend,
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
      'MESSAGE_POLL_VOTE_ADD': parseMessagePollVoteAdd,
      'MESSAGE_POLL_VOTE_REMOVE': parseMessagePollVoteRemove,
      'GUILD_SOUNDBOARD_SOUND_CREATE': parseSoundboardSoundCreate,
      'GUILD_SOUNDBOARD_SOUND_UPDATE': parseSoundboardSoundUpdate,
      'GUILD_SOUNDBOARD_SOUND_DELETE': parseSoundboardSoundDelete,
      'GUILD_SOUNDBOARD_SOUNDS_UPDATE': parseSoundboardSoundsUpdate,
    };

    return mapping[raw.name]?.call(raw.payload, client) ?? UnknownDispatchEvent(client: client, raw: raw);
  }
}
