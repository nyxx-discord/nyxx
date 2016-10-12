part of discord;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  GuildCreateEvent._new(Client client, Map<String, dynamic> json, _WS ws) {
    this.guild =
        new Guild._new(client, json['d'] as Map<String, dynamic>, true, true);
    client.guilds.add(guild);

    guild.channels.list.forEach((GuildChannel v) {
      client.channels.add(v);
    });

    guild.members.list.forEach((Member v) {
      client.users.add(v.toUser());
    });

    json['d']['presences'].forEach((Map<String, dynamic> o) {
      Member member = guild.members[o['user']['id']];
      member.status = member._map['status'] = o['status'];
      if (o['game'] != null) {
        member.game = member._map['game'] =
            new Game._new(client, o['game'] as Map<String, dynamic>);
      }
    });

    if (!client.ready) {
      bool match = true;
      client.guilds.forEach((Guild o) {
        if (o == null) match = false;
      });

      bool match2 = true;
      ws.shards.forEach((_Shard s) {
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
