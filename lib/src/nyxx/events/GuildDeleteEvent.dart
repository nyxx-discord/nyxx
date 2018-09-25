part of nyxx;

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  GuildDeleteEvent._new( Map<String, dynamic> json, Shard shard) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['id'] as String)];

      client.guilds.remove(guild.id);
      shard.guilds.remove(guild.id);
      client._events.onGuildDelete.add(this);
    }
  }
}
