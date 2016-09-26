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
      this.oldMember = guild.members.get(json['d']['user']['id']);
      this.newMember = new Member(client, json['d'], guild);
      guild.members.map[newMember.user.id] = newMember;
      client.users.map[newMember.user.id] = newMember.user;
      client.emit('guildMemberUpdate', this);
    }
  }
}
