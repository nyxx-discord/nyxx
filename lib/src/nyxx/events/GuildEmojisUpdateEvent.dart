part of nyxx;

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// New list of changes emojis
  Map<Snowflake, GuildEmoji> emojis;

  GuildEmojisUpdateEvent._new( Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      emojis = Map();
      json['d']['emojis'].forEach((o) {
        var emoji = GuildEmoji._new(o as Map<String, dynamic>, guild);
        guild.emojis[emoji.id] = emoji;
        emojis[emoji.id] = emoji;
      });
      client._events.onGuildEmojisUpdate.add(this);
    }
  }
}
