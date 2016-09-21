import '../../objects.dart';
import '../client.dart';

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild prior to the update.
  Guild oldGuild;

  /// The guild after the update.
  Guild newGuild;

  /// Constructs a new [GuildUpdateEvent].
  GuildUpdateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      Guild newGuild = new Guild(client, json['d']);
      Guild oldGuild = client.guilds[newGuild.id];
      newGuild.channels = oldGuild.channels;
      newGuild.members = oldGuild.members;

      client.guilds[newGuild.id] = newGuild;

      client.emit('guildCreate', this);
    }
  }
}
