import 'dart:convert';
import '../../discord.dart';
import 'package:http/http.dart' as http;

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
        if (client.user.bot) {
          client.internal.http
              .get('/oauth2/applications/@me')
              .then((http.Response r) {
            final res = JSON.decode(r.body) as Map<String, dynamic>;

            if (r.statusCode == 200) {
              client.app = new ClientOAuth2Application(client, res);
            }

            new ReadyEvent(client);
          });
        }
      }
    } else {
      client.internal.events.onGuildCreate.add(this);
    }
  }
}
