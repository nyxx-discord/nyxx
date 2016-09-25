import '../../discord.dart';
import '../client.dart';

/// Sent when you leave a guild or it becomes unavailable.
class GuildDeleteEvent {
  /// If the guild is unavailable or not, if `false`, you left the guild.
  bool unavailable;

  /// The guild, will be an unavailable guild if the guild is unavailable.
  Guild guild;

  /// Constructs a new [GuildDeleteEvent].
  GuildDeleteEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['unavailable']) {
        this.unavailable = true;
        this.guild = new Guild(client, null, false);
        client.guilds.map[json['d']['id']] = guild;
        client.emit('guildDelete', this);
      } else {
        this.unavailable = false;
        this.guild = client.guilds.map[json['d']['id']];
        client.guilds.map.remove(json['d']['id']);
        client.emit('guildDelete', this);
      }
    }
  }
}
