import '../../objects.dart';
import '../../events.dart';
import '../client.dart';

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  GuildCreateEvent(Client client, Map json) {
    this.guild = new Guild(client, json['d'], true, true);
    client.guilds[guild.id] = guild;

    guild.channels.forEach((i, v) {
      client.channels[v.id] = v;
    });

    guild.members.forEach((i, v) {
      client.users[v.user.id] = v.user;
    });

    if (!client.ready) {
      bool match = true;
      client.guilds.forEach((i, o) {
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
