import '../../discord.dart';
import '../client.dart';

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild guild;

  ///The user that left.
  User user;

  /// Constructs a new [GuildMemberRemoveEvent].
  GuildMemberRemoveEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds.map[json['d']['guild_id']];
      this.user = new User(client, json['d']['user']);
      guild.members.map.remove(user.id);
      client.users.map[user.id] = user;
      client.emit('guildMemberRemove', this);
    }
  }
}
