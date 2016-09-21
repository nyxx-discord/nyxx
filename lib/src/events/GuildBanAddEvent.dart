import '../../objects.dart';
import '../client.dart';

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild guild;

  /// The user that was banned.
  User user;

  GuildBanAddEvent(Client client, Map json) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['guild_id']];
      this.user = new User(json['d']['user']);
      client.users[user.id] = user;
      client.emit('guildBanAdd', this);
    }
  }
}
