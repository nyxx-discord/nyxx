import '../../discord.dart';

/// Sent when a channel is deleted, can be a `PMChannel`.
class ChannelDeleteEvent {
  /// The channel that was deleted, either a `GuildChannel` or `PMChannel`.
  dynamic channel;

  /// Constructs a new [ChannelDeleteEvent].
  ChannelDeleteEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new PrivateChannel(client, json['d'] as Map<String, dynamic>);
        client.channels.map.remove(channel.id);
        client.emit('channelDelete', this);
      } else {
        final Guild guild = client.guilds.map[json['d']['guild_id']];
        this.channel =
            new GuildChannel(client, json['d'] as Map<String, dynamic>, guild);
        client.channels.map.remove(channel.id);
        client.emit('channelDelete', this);
      }
    }
  }
}
