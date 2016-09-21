import '../../objects.dart';
import '../client.dart';

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild guild;

  ///The user that left.
  User user;

  GuildMemberRemoveEvent(Client client, Map json) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['guild_id']];
      this.user = new User(json['d']['user']);
      guild.members.remove(user.id);
      client.users[user.id] = user;
      client.emit('guildMemberRemove', this);
    }
  }
}
