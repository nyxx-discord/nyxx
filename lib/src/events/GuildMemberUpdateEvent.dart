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
      final Guild guild = client.guilds[json['d']['guild_id']];
      this.oldMember = guild.members[json['d']['user']['id']];
      this.newMember = new Member(json['d'], guild);
      guild.members[newMember.user.id] = newMember;
      client.users[newMember.user.id] = newMember.user;
      client.emit('guildMemberUpdate', this);
    }
  }
}
