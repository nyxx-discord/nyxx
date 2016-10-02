import '../../discord.dart';

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  /// Constructs a new [GuildCreateEvent].
  GuildCreateEvent(Client client, Map<String, dynamic> json) {
    this.guild =
        new Guild(client, json['d'] as Map<String, dynamic>, true, true);
    client.guilds.add(guild);

    guild.channels.list.forEach((GuildChannel v) {
      client.channels.add(v);
    });

    guild.members.list.forEach((Member v) {
      client.users.add(v.toUser());
    });

    if (!client.ready) {
      bool match = true;
      client.guilds.forEach((Guild o) {
        if (o == null) {
          match = false;
        }
      });

      if (match == true) {
        client.ready = true;
        new ReadyEvent(client);
      }
    } else {
      client.internal.events.onGuildCreate.add(this);
    }
  }
}
