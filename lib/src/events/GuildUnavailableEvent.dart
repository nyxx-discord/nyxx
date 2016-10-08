part of discord;

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  /// Constructs a new [GuildUnavailableEvent].
  GuildUnavailableEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = new Guild(client, null, false);
      client.guilds.map[json['d']['id']] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}
