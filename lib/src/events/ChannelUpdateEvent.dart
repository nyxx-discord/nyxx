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
      this.newChannel = new GuildChannel(client, json['d'], guild);
      client.channels.map[newChannel.id] = newChannel;
      client.emit('channelUpdate', this);
    }
  }
}
