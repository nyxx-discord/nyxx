part of discord;

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  /// Constructs a new [GuildDeleteEvent].
  GuildDeleteEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds.map[json['d']['id']];
      client.guilds.map.remove(json['d']['id']);
      client._events.onGuildDelete.add(this);
    }
  }
}
