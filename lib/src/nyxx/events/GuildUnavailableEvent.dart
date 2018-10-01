part of nyxx;

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  GuildUnavailableEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = Guild._new(null, false);
      client.guilds[guild.id] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}
