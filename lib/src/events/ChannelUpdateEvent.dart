import '../../discord.dart';

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  /// Constructs a new [ChannelUpdateEvent].
  ChannelUpdateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds.map[json['d']['guild_id']];
      this.oldChannel = client.channels.map[json['d']['id']];
      if (json['d']['type'] == 0) {
        this.newChannel =
            new TextChannel(client, json['d'] as Map<String, dynamic>, guild);
      } else {
        this.newChannel =
            new VoiceChannel(client, json['d'] as Map<String, dynamic>, guild);
      }
      client.channels.map[newChannel.id] = newChannel;
      client.internal.events.onChannelUpdate.add(this);
    }
  }
}
