part of discord;

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  GuildUnavailableEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = new Guild._new(client, null, false);
      client.guilds[json['d']['id']] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}
