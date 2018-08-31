part of nyxx;

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild prior to the update.
  Guild oldGuild;

  /// The guild after the update.
  Guild newGuild;

  GuildUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.newGuild = Guild._new(client, json['d'] as Map<String, dynamic>);
      this.oldGuild = client.guilds[this.newGuild.id];
      this.newGuild.channels = this.oldGuild.channels;
      this.newGuild.members = this.oldGuild.members;

      client._events.onGuildUpdate.add(this);
    }
  }
}
