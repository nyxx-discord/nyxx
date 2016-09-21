import '../../objects.dart';
import '../client.dart';

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent(Client client, Map json) {
    if (client.ready) {
      Guild guild = client.guilds[json['d']['guild_id']];
      this.member = new Member(json['d'], guild);
      guild.members[member.user.id] = member;
      client.users[member.user.id] = member.user;
      client.emit('guildMemberAdd', this);
    }
  }
}
