part of discord;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  GuildCreateEvent._new(Client client, Map<String, dynamic> json, _WS ws) {
    this.guild =
        new Guild._new(client, json['d'] as Map<String, dynamic>, true, true);
    client.guilds.add(guild);

    if (!client.ready) {
      bool match = true;
      client.guilds.forEach((Guild o) {
        if (o == null) match = false;
      });

      bool match2 = true;
      ws.client.shards.forEach((Shard s) {
        if (!s.ready) match = false;
      });

      if (match && match2) {
        client.ready = true;
        if (client.user.bot) {
          client._http
              .get('/oauth2/applications/@me', true)
              .then((_HttpResponse r) {
            client.app = new ClientOAuth2Application._new(client, r.json);
            new ReadyEvent._new(client);
          });
        } else {
          new ReadyEvent._new(client);
        }
      }
    } else {
      client._events.onGuildCreate.add(this);
    }
  }
}
