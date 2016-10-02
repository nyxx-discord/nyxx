import '../../discord.dart';

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild prior to the update.
  Guild oldGuild;

  /// The guild after the update.
  Guild newGuild;

  /// Constructs a new [GuildUpdateEvent].
  GuildUpdateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.newGuild = new Guild(client, json['d'] as Map<String, dynamic>);
      this.oldGuild = client.guilds.map[this.newGuild.id];
      this.newGuild.channels = this.oldGuild.channels;
      this.newGuild.members = this.oldGuild.members;

      client.guilds.map[this.newGuild.id] = this.newGuild;

      client.internal.events.onGuildUpdate.add(this);
    }
  }
}
