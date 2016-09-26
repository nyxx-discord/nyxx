import '../../discord.dart';
import '../client.dart';

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  /// Constructs a new [GuildCreateEvent].
  GuildCreateEvent(Client client, Map<String, dynamic> json) {
    this.guild = new Guild(client, json['d'], true, true);
    client.guilds.map[guild.id] = guild;

    guild.channels.list.forEach((GuildChannel v) {
      client.channels.map[v.id] = v;
    });

    guild.members.list.forEach((Member v) {
      client.users.map[v.user.id] = v.user;
    });

    if (!client.ready) {
      bool match = true;
      client.guilds.map.forEach((String i, Guild o) {
        if (o == null) {
          match = false;
        }
      });

      if (match == true) {
        client.ready = true;
        client.emit('ready', new ReadyEvent());
      }
    } else {
      client.emit('guildCreate', this);
    }
  }
}
