part of nyxx;

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  GuildUnavailableEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = new Guild._new(client, null, false);
      client.guilds[new Snowflake(json['d']['id'] as String)] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}
