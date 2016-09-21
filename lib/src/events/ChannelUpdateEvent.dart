import '../../objects.dart';
import '../client.dart';

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  ChannelUpdateEvent(Client client, Map json) {
    if (client.ready) {
      Guild guild = client.guilds[json['d']['guild_id']];
      this.oldChannel = client.channels[json['d']['id']];
      this.newChannel = new GuildChannel(client, json['d'], guild);
      client.channels[newChannel.id] = newChannel;
      client.emit('channelUpdate', this);
    }
  }
}
