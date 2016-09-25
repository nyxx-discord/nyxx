import '../../discord.dart';
import '../client.dart';

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  /// Constructs a new [GuildCreateEvent].
  GuildCreateEvent(Client client, Map<String, dynamic> json) {
    this.guild = new Guild(client, json['d'], true, true);
    client.guilds[guild.id] = guild;

    guild.channels.forEach((String i, GuildChannel v) {
      client.channels[v.id] = v;
    });

    guild.members.forEach((String i, Member v) {
      client.users[v.user.id] = v.user;
    });

    if (!client.ready) {
      bool match = true;
      client.guilds.forEach((String i, Guild o) {
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
