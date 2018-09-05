part of nyxx;

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  GuildDeleteEvent._new(Nyxx client, Map<String, dynamic> json, Shard shard) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['id'] as String)];
      client.guilds.remove(Snowflake(json['d']['id'] as String));
      shard.guilds.remove(Snowflake(json['d']['id'] as String));
      client._events.onGuildDelete.add(this);
    }
  }
}
