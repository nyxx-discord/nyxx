part of nyxx;

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// New list of changes emojis
  Map<String, GuildEmoji> emojis;

  GuildEmojisUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[json['d']['guild_id']];
      emojis = new Map();
      json['d']['emojis'].forEach((Map<String, dynamic> o) {
        emojis[o['id']] = new GuildEmoji._new(client, o, guild);
      });
      client._events.onGuildEmojisUpdate.add(this);
    }
  }
}
