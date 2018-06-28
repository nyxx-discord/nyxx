part of nyxx;

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  GuildDeleteEvent._new(Client client, Map<String, dynamic> json, Shard shard) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['id']];
      client.guilds.remove(json['d']['id']);
      shard.guilds.remove(json['d']['id']);
      client._events.onGuildDelete.add(this);
    }
  }
}
