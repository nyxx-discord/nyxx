import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/guild/audit_log.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

/// {@template unavailable_guild_create_event}
/// Emitted when the client is added to an unavailable guild, or when initially receiving guilds over the Gateway.
/// {@endtemplate}
class UnavailableGuildCreateEvent extends DispatchEvent {
  /// The guild the client was added to.
  final PartialGuild guild;

  /// {@macro unavailable_guild_create_event}
  /// @nodoc
  UnavailableGuildCreateEvent({required super.gateway, required this.guild});
}

/// {@template guild_create_event}
/// Emitted when a client is added to a guild or when initially receiving guilds over the Gateway.
/// {@endtemplate}
class GuildCreateEvent extends DispatchEvent implements UnavailableGuildCreateEvent {
  @override
  final Guild guild;

  /// The time at which the client joined the guild.
  final DateTime joinedAt;

  /// Whether the guild is large.
  final bool isLarge;

  /// The number of members in the guild.
  final int memberCount;

  /// A list of the [VoiceState]s of members currently in voice channels.
  final List<VoiceState> voiceStates;

  /// A list of members in the guild.
  final List<Member> members;

  /// A list of channels in the guild.
  final List<GuildChannel> channels;

  /// A list of threads in the guild.
  final List<Thread> threads;

  /// A list of initial presence update events in the guild.
  final List<PresenceUpdateEvent> presences;

  /// A list of stage instances in the guild.
  final List<StageInstance> stageInstances;

  /// A list of scheduled events in the guild.
  final List<ScheduledEvent> scheduledEvents;

  /// {@macro guild_create_event}
  /// @nodoc
  GuildCreateEvent({
    required super.gateway,
    required this.guild,
    required this.joinedAt,
    required this.isLarge,
    required this.memberCount,
    required this.voiceStates,
    required this.members,
    required this.channels,
    required this.threads,
    required this.presences,
    required this.stageInstances,
    required this.scheduledEvents,
  });
}

/// {@template guild_update_event}
/// Emitted when a guild is updated.
/// {@endtemplate}
class GuildUpdateEvent extends DispatchEvent {
  /// The guild as it was cached before the update.
  final Guild? oldGuild;

  /// The updated guild.
  final Guild guild;

  /// {@macro guild_update_event}
  /// @nodoc
  GuildUpdateEvent({required super.gateway, required this.oldGuild, required this.guild});
}

/// {@template guild_delete_event}
/// Emitted when the client is removed from a guild.
/// {@endtemplate}
class GuildDeleteEvent extends DispatchEvent {
  /// The guild the client was removed from.
  final PartialGuild guild;

  /// Whether the client was removed because the guild is unavailable.
  final bool isUnavailable;

  /// {@macro guild_delete_event}
  /// @nodoc
  GuildDeleteEvent({required super.gateway, required this.guild, required this.isUnavailable});
}

/// {@template guild_audit_log_create_event}
/// Emitted when an audit log entry is created in a guild.
/// {@endtemplate}
class GuildAuditLogCreateEvent extends DispatchEvent {
  /// The entry that was created.
  final AuditLogEntry entry;

  /// The ID of the guild in which the entry was created.
  final Snowflake guildId;

  /// {@macro guild_audit_log_create_event}
  /// @nodoc
  GuildAuditLogCreateEvent({required super.gateway, required this.entry, required this.guildId});

  /// The guild in which the entry was created.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_ban_add_event}
/// Emitted when a user is banned in a guild.
/// {@endtemplate}
class GuildBanAddEvent extends DispatchEvent {
  /// The ID of the guild the user was banned in.
  final Snowflake guildId;

  /// The banned user.
  final User user;

  /// {@macro guild_ban_add_event}
  /// @nodoc
  GuildBanAddEvent({required super.gateway, required this.guildId, required this.user});

  /// The guild in which the user was banned.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_ban_remove_event}
/// Emitted when a user is unbanned in a guild.
/// {@endtemplate}
class GuildBanRemoveEvent extends DispatchEvent {
  /// The ID of the guild the user was unbanned from.
  final Snowflake guildId;

  /// The unbanned user.
  final User user;

  /// {@macro guild_ban_remove_event}
  /// @nodoc
  GuildBanRemoveEvent({required super.gateway, required this.guildId, required this.user});

  /// The guild in which the user was unbanned.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_emojis_update_event}
/// Emitted when a guild's emojis are updated.
/// {@endtemplate}
class GuildEmojisUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The updated emojis.
  final List<Emoji> emojis;

  /// {@macro guild_emojis_update_event}
  /// @nodoc
  GuildEmojisUpdateEvent({required super.gateway, required this.guildId, required this.emojis});

  /// The guild in which emojis were updated.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_stickers_update_event}
/// Emitted when a guild's stickers are updated.
/// {@endtemplate}
class GuildStickersUpdateEvent extends DispatchEvent {
  /// The ID ot the guild.
  final Snowflake guildId;

  /// Array of updated stickers.
  final List<GuildSticker> stickers;

  /// {@macro guild_stickers_update_event}
  /// @nodoc
  GuildStickersUpdateEvent({required super.gateway, required this.guildId, required this.stickers});

  /// The guild in which the stickers were updated.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_integrations_update_event}
/// Emitted when a guild's integrations are updated.
/// {@endtemplate}
class GuildIntegrationsUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// {@macro guild_integrations_update_event}
  /// @nodoc
  GuildIntegrationsUpdateEvent({required super.gateway, required this.guildId});

  /// The guild in which the integrations were updated.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_member_add_event}
/// Emitted when a member joins a guild.
/// {@endtemplate}
class GuildMemberAddEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The added member.
  final Member member;

  /// {@macro guild_member_add_event}
  /// @nodoc
  GuildMemberAddEvent({required super.gateway, required this.guildId, required this.member});

  /// The guild in which the member was added.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_member_remove_event}
/// Emitted when a member is removed from a guild.
/// {@endtemplate}
class GuildMemberRemoveEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The removed user.
  final User user;

  /// {@macro guild_member_remove_event}
  /// @nodoc
  GuildMemberRemoveEvent({required super.gateway, required this.guildId, required this.user});

  /// The guild in which the member was removed.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_member_update_event}
/// Emitted when a guild member is updated.
/// {@endtemplate}
class GuildMemberUpdateEvent extends DispatchEvent {
  /// The member as it was cached before the update.
  final Member? oldMember;

  /// The updated member.
  final Member member;

  /// The ID of the guild.
  final Snowflake guildId;

  /// {@macro guild_member_update_event}
  /// @nodoc
  GuildMemberUpdateEvent({required super.gateway, required this.oldMember, required this.member, required this.guildId});

  /// The guild in which the member was updated.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_members_chunk_event}
/// Emitted as a response to [Gateway.listGuildMembers].
/// {@endtemplate}
class GuildMembersChunkEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The members in this chunk.
  final List<Member> members;

  /// The index of this chunk.
  final int chunkIndex;

  /// The total number of chunks.
  final int chunkCount;

  /// A list of IDs that were not found in the guild.
  final List<Snowflake>? notFound;

  /// A list of presences for the [members] in this chunk.
  final List<PresenceUpdateEvent>? presences;

  /// The custom nonce set when requesting the members.
  final String? nonce;

  /// {@macro guild_members_chunk_event}
  /// @nodoc
  GuildMembersChunkEvent({
    required super.gateway,
    required this.guildId,
    required this.members,
    required this.chunkIndex,
    required this.chunkCount,
    required this.notFound,
    required this.presences,
    required this.nonce,
  });

  /// The guild members are being sent from.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_role_create_event}
/// Emitted when a role is created in a guild.
/// {@endtemplate}
class GuildRoleCreateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The created role.
  final Role role;

  /// {@macro guild_role_create_event}
  /// @nodoc
  GuildRoleCreateEvent({required super.gateway, required this.guildId, required this.role});

  /// The guild in which the role was created.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_role_update_event}
/// Emitted when a role is updated in a guild
/// {@endtemplate}
class GuildRoleUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The role as it was cached before the update.
  final Role? oldRole;

  /// The updated role.
  final Role role;

  /// {@macro guild_role_update_event}
  /// @nodoc
  GuildRoleUpdateEvent({required super.gateway, required this.guildId, required this.oldRole, required this.role});

  /// The guild in which the role was updated.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_role_delete_event}
/// Emitted when a role is deleted in a guild.
/// {@endtemplate}
class GuildRoleDeleteEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the deleted role.
  final Snowflake roleId;

  /// {@macro guild_role_delete_event}
  /// @nodoc
  GuildRoleDeleteEvent({required super.gateway, required this.roleId, required this.guildId});

  /// The guild in which the role was deleted.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template guild_scheduled_event_create_event}
/// Emitted when a scheduled event is created.
/// {@endtemplate}
class GuildScheduledEventCreateEvent extends DispatchEvent {
  /// The event that was created.
  final ScheduledEvent event;

  /// {@macro guild_scheduled_event_create_event}
  /// @nodoc
  GuildScheduledEventCreateEvent({required super.gateway, required this.event});
}

/// {@template guild_scheduled_event_update_event}
/// Emitted when a scheduled event is updated.
/// {@endtemplate}
class GuildScheduledEventUpdateEvent extends DispatchEvent {
  /// The event as it was in the cache before it was updated.
  final ScheduledEvent? oldEvent;

  /// The updated event.
  final ScheduledEvent event;

  /// {@macro guild_scheduled_event_update_event}
  /// @nodoc
  GuildScheduledEventUpdateEvent({required super.gateway, required this.oldEvent, required this.event});
}

/// {@template guild_scheduled_event_delete_event}
/// Emitted when a scheduled event is deleted.
/// {@endtemplate}
class GuildScheduledEventDeleteEvent extends DispatchEvent {
  /// The event that was deleted.
  final ScheduledEvent event;

  /// {@macro guild_scheduled_event_delete_event}
  /// @nodoc
  GuildScheduledEventDeleteEvent({required super.gateway, required this.event});
}

/// {@template guild_scheduled_event_user_add_event}
/// Emitted when a user is added to a scheduled event.
/// {@endtemplate}
class GuildScheduledEventUserAddEvent extends DispatchEvent {
  /// The ID of the scheduled event.
  final Snowflake scheduledEventId;

  /// The ID of the added user.
  final Snowflake userId;

  /// The ID of the guild.
  final Snowflake guildId;

  /// {@macro guild_scheduled_event_user_add_event}
  /// @nodoc
  GuildScheduledEventUserAddEvent({required super.gateway, required this.scheduledEventId, required this.userId, required this.guildId});

  /// The guild that the scheduled event is in.
  PartialGuild get guild => gateway.client.guilds[guildId];

  /// The scheduled event.
  PartialScheduledEvent get scheduledEvent => guild.scheduledEvents[scheduledEventId];

  /// The user that was added.
  PartialUser get user => gateway.client.users[userId];

  /// The member that was added.
  PartialMember get member => guild.members[userId];
}

/// {@template guild_scheduled_event_user_remove_event}
/// Emitted when a user is removed from a scheduled event.
/// {@endtemplate}
class GuildScheduledEventUserRemoveEvent extends DispatchEvent {
  /// The ID of the scheduled event.
  final Snowflake scheduledEventId;

  /// The ID of the user.
  final Snowflake userId;

  /// The ID of the guild.
  final Snowflake guildId;

  /// {@macro guild_scheduled_event_user_remove_event}
  /// @nodoc
  GuildScheduledEventUserRemoveEvent({required super.gateway, required this.scheduledEventId, required this.userId, required this.guildId});

  /// The guild that the scheduled event is in.
  PartialGuild get guild => gateway.client.guilds[guildId];

  /// The scheduled event.
  PartialScheduledEvent get scheduledEvent => guild.scheduledEvents[scheduledEventId];

  /// The user that was removed.
  PartialUser get user => gateway.client.users[userId];

  /// The member that was removed.
  PartialMember get member => guild.members[userId];
}
