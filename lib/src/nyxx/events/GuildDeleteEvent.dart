part of nyxx;

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  GuildDeleteEvent._new(Client client, Map<String, dynamic> json, Shard shard) {
    if (client.ready) {
      this.guild = client.guilds[new Snowflake(json['d']['id'] as String)];
      client.guilds.remove(new Snowflake(json['d']['id'] as String));
      shard.guilds.remove(new Snowflake(json['d']['id'] as String));
      client._events.onGuildDelete.add(this);
    }
  }
}
