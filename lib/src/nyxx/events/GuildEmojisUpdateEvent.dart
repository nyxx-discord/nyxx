part of nyxx;

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// New list of changes emojis
  Map<Snowflake, GuildEmoji> emojis;

  GuildEmojisUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[new Snowflake(json['d']['guild_id'] as String)];
      emojis = new Map();
      json['d']['emojis'].forEach((dynamic o) {
        emojis[new Snowflake(o['id'] as String)] =
            new GuildEmoji._new(client, o as Map<String, dynamic>, guild);
      });
      client._events.onGuildEmojisUpdate.add(this);
    }
  }
}
