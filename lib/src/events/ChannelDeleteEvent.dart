import '../../objects.dart';
import '../client.dart';

/// Sent when a channel is deleted, can be a [PMChannel].
class ChannelDeleteEvent {
  /// The channel that was deleted, either a [GuildChannel] or [PMChannel].
  dynamic channel;

  ChannelDeleteEvent(Client client, Map json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel = new PrivateChannel(json['d']);
        client.channels.remove(channel.id);
        client.emit('channelDelete', this);
      } else {
        Guild guild = client.guilds[json['d']['guild_id']];
        this.channel = new GuildChannel(client, json['d'], guild);
        client.channels.remove(channel.id);
        client.emit('channelDelete', this);
      }
    }
  }
}
