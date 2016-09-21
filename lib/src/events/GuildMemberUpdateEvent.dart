import '../../objects.dart';
import '../client.dart';

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  GuildMemberUpdateEvent(Client client, Map json) {
    if (client.ready) {
      Guild guild = client.guilds[json['d']['guild_id']];
      this.oldMember = guild.members[json['d']['user']['id']];
      this.newMember = new Member(json['d'], guild);
      guild.members[newMember.user.id] = newMember;
      client.users[newMember.user.id] = newMember.user;
      client.emit('guildMemberUpdate', this);
    }
  }
}
