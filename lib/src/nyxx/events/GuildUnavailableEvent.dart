part of nyxx;

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  GuildUnavailableEvent._new(Nyxx client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = Guild._new(client, null, false);
      client.guilds[Snowflake(json['d']['id'] as String)] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}
