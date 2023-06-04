import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

class UnavailableGuildCreateEvent extends DispatchEvent {
  final PartialGuild guild;

  UnavailableGuildCreateEvent({required this.guild});
}

class GuildCreateEvent extends DispatchEvent implements UnavailableGuildCreateEvent {
  @override
  final Guild guild;

  final DateTime joinedAt;

  final bool isLarge;

  final int memberCount;

  // TODO: These are partial
  final List<VoiceState> voiceStates;

  final List<Member> members;

  final List<GuildChannel> channels;

  final List<Thread> threads;

  // TODO
  //final List<PartialPresence> presences;

  // TODO
  //final List<StageInstance> stageInstances;

  // TODO
  //final List<ScheduledEvent> scheduledEvents;

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

class GuildUpdateEvent extends DispatchEvent {
  final Guild? oldGuild;

  final Guild guild;

  GuildUpdateEvent({required this.oldGuild, required this.guild});
}

class GuildDeleteEvent extends DispatchEvent {
  final PartialGuild guild;

  final bool isUnavailable;

  GuildDeleteEvent({required this.guild, required this.isUnavailable});
}

class GuildBanAddEvent extends DispatchEvent {
  final Snowflake guildId;

  final User user;

  GuildBanAddEvent({required this.guildId, required this.user});
}

class GuildBanRemoveEvent extends DispatchEvent {
  final Snowflake guildId;

  final User user;

  GuildBanRemoveEvent({required this.guildId, required this.user});
}

class GuildEmojisUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  // TODO
  //final List<Emoji> emojis;

  GuildEmojisUpdateEvent({required this.guildId});
}

class GuildStickersUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  // TODO
  //final List<Sticker> emojis;

  GuildStickersUpdateEvent({required this.guildId});
}

class GuildIntegrationsUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  GuildIntegrationsUpdateEvent({required this.guildId});
}

class GuildMemberAddEvent extends DispatchEvent {
  final Snowflake guildId;

  final Member member;

  GuildMemberAddEvent({required this.guildId, required this.member});
}

class GuildMemberRemoveEvent extends DispatchEvent {
  final Snowflake guildId;

  final User user;

  GuildMemberRemoveEvent({required this.guildId, required this.user});
}

class GuildMemberUpdateEvent extends DispatchEvent {
  final Member? oldMember;

  final Member member;

  final Snowflake guildId;

  GuildMemberUpdateEvent({required this.oldMember, required this.member, required this.guildId});
}

class GuildMembersChunkEvent extends DispatchEvent {
  final Snowflake guildId;

  final List<Member> members;

  final int chunkIndex;

  final int chunkCount;

  final List<Snowflake>? notFound;

  // TODO
  //final List<Presence> presences;

  final String? nonce;

  GuildMembersChunkEvent({
    required this.guildId,
    required this.members,
    required this.chunkIndex,
    required this.chunkCount,
    required this.notFound,
    required this.nonce,
  });
}

class GuildRoleCreateEvent extends DispatchEvent {
  final Snowflake guildId;

  final Role role;

  GuildRoleCreateEvent({required this.guildId, required this.role});
}

class GuildRoleUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  final Role? oldRole;

  final Role role;

  GuildRoleUpdateEvent({required this.guildId, required this.oldRole, required this.role});
}

class GuildRoleDeleteEvent extends DispatchEvent {
  final Snowflake guildId;

  final Snowflake roleId;

  GuildRoleDeleteEvent({required this.roleId, required this.guildId});
}

class GuildScheduledEventCreateEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
}

class GuildScheduledEventUpdateEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
}

class GuildScheduledEventDeleteEvent extends DispatchEvent {
  // TODO
  //final ScheduledEvent event;
}

class GuildScheduledEventUserAddEvent extends DispatchEvent {
  final Snowflake scheduledEventId;

  final Snowflake userId;

  final Snowflake guildId;

  GuildScheduledEventUserAddEvent({required this.scheduledEventId, required this.userId, required this.guildId});
}

class GuildScheduledEventUserRemoveEvent extends DispatchEvent {
  final Snowflake scheduledEventId;

  final Snowflake userId;

  final Snowflake guildId;

  GuildScheduledEventUserRemoveEvent({required this.scheduledEventId, required this.userId, required this.guildId});
}
