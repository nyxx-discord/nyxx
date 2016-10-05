import '../../discord.dart';

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  /// Constructs a new [GuildMemberUpdateEvent].
  GuildMemberUpdateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds.map[json['d']['guild_id']];
      this.oldMember = guild.members[json['d']['user']['id']];
      this.newMember =
          new Member(client, json['d'] as Map<String, dynamic>, guild);
      guild.members.map[newMember.id] = newMember;
      client.users.map[newMember.id] = newMember.toUser();
      client.internal.events.onGuildMemberUpdate.add(this);
    }
  }
}
