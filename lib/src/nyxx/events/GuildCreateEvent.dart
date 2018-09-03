part of nyxx;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  GuildCreateEvent._new(Client client, Map<String, dynamic> json, Shard shard) {
    this.guild =
        Guild._new(client, json['d'] as Map<String, dynamic>, true, true);

    if (shard._ws.client._options.forceFetchMembers)
      shard.send("REQUEST_GUILD_MEMBERS",
          {"guild_id": guild.id.toString(), "query": "", "limit": 0});

    if (!client.ready) {
      shard._ws.testReady();
    } else {
      client._events.onGuildCreate.add(this);
    }
  }
}
