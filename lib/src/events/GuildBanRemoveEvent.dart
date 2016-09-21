import '../../objects.dart';
import '../client.dart';

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild guild;

  /// The user that was unbanned.
  User user;

  GuildBanRemoveEvent(Client client, Map json) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['guild_id']];
      this.user = new User(json['d']['user']);
      client.users[user.id] = user;
      client.emit('guildBanRemove', this);
    }
  }
}
