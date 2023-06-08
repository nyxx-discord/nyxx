import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

/// {@template unavailable_guild_create_event}
/// Emitted when the client is added to an unavailable guild, or when initially receiving guilds over the Gateway.
/// {@endtemplate}
class UnavailableGuildCreateEvent extends DispatchEvent {
  /// The guild the client was added to.
  final PartialGuild guild;

  /// {@macro unavailable_guild_create_event}
  UnavailableGuildCreateEvent({required this.guild});
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
  // TODO: These are partial
  final List<VoiceState> voiceStates;

  /// A list of members in the guild.
  final List<Member> members;

  /// A list of channels in the guild.
  final List<GuildChannel> channels;

  /// A list of threads in the guild.
  final List<Thread> threads;

  // TODO
  //final List<PartialPresence> presences;

  // TODO
  //final List<StageInstance> stageInstances;

  // TODO
  //final List<ScheduledEvent> scheduledEvents;

  /// {@macro guild_create_event}
  GuildCreateEvent({
    required this.guild,
    required this.joinedAt,
    required this.isLarge,
    required this.memberCount,
    required this.voiceStates,
    required this.members,
    required this.channels,
    required this.threads,
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
  GuildUpdateEvent({required this.oldGuild, required this.guild});
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
  GuildDeleteEvent({required this.guild, required this.isUnavailable});
}

/// {@template guild_audit_log_create_event}
/// Emitted when an audit log entry is created in a guild.
/// {@endtemplate}
class GuildAuditLogCreateEvent extends DispatchEvent {
  // TODO
  //final AuditLogEntry entry;

  /// {@macro guild_audit_log_create_event}
  GuildAuditLogCreateEvent();
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
  GuildBanAddEvent({required this.guildId, required this.user});
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
  GuildBanRemoveEvent({required this.guildId, required this.user});
}

/// {@template guild_emojis_update_event}
/// Emitted when a guild's emojis are updated.
/// {@endtemplate}
class GuildEmojisUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  // TODO
  //final List<Emoji> emojis;

  /// {@macro guild_emojis_update_event}
  GuildEmojisUpdateEvent({required this.guildId});
}

/// {@template guild_stickers_update_event}
/// Emitted when a guild's stickers are updated.
/// {@endtemplate}
class GuildStickersUpdateEvent extends DispatchEvent {
  /// The IF ot the guild.
  final Snowflake guildId;

  // TODO
  //final List<Sticker> emojis;

  /// {@macro guild_stickers_update_event}
  GuildStickersUpdateEvent({required this.guildId});
}

/// {@template guild_integrations_update_event}
/// Emitted when a guild's integrations are updated.
/// {@endtemplate}
class GuildIntegrationsUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// {@macro guild_integrations_update_event}
  GuildIntegrationsUpdateEvent({required this.guildId});
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
  GuildMemberAddEvent({required this.guildId, required this.member});
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
  GuildMemberRemoveEvent({required this.guildId, required this.user});
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
  GuildMemberUpdateEvent({required this.oldMember, required this.member, required this.guildId});
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

  // TODO
  //final List<Presence> presences;

  /// The custom nonce set when requesting the members.
  final String? nonce;

  /// {@macro guild_members_chunk_event}
  GuildMembersChunkEvent({
    required this.guildId,
    required this.members,
    required this.chunkIndex,
    required this.chunkCount,
    required this.notFound,
    required this.nonce,
  });
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
  GuildRoleCreateEvent({required this.guildId, required this.role});
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
  GuildRoleUpdateEvent({required this.guildId, required this.oldRole, required this.role});
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
  GuildRoleDeleteEvent({required this.roleId, required this.guildId});
}

/// {@template guild_scheduled_event_create_event}
/// Emitted when a scheduled event is created.
/// {@endtemplate}
class GuildScheduledEventCreateEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
}

/// {@template guild_scheduled_event_update_event}
/// Emitted when a scheduled event is updated.
/// {@endtemplate}
class GuildScheduledEventUpdateEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
}

/// {@template guild_scheduled_event_delete_event}
/// Emitted when a scheduled event is deleted.
/// {@endtemplate}
class GuildScheduledEventDeleteEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
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
  GuildScheduledEventUserAddEvent({required this.scheduledEventId, required this.userId, required this.guildId});
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
  GuildScheduledEventUserRemoveEvent({required this.scheduledEventId, required this.userId, required this.guildId});
}
