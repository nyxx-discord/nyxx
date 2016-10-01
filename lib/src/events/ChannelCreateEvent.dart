import '../../discord.dart';

/// Sent when a channel is created, can be a [PrivateChannel].
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel] or [PrivateChannel].
  dynamic channel;

  /// Constructs a new [ChannelCreateEvent].
  ChannelCreateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new PrivateChannel(client, json['d'] as Map<String, dynamic>);
        client.channels.map[channel.id] = channel;
        client.internal.events.onChannelCreate.add(this);
      } else {
        final Guild guild = client.guilds.map[json['d']['guild_id']];
        this.channel =
            new GuildChannel(client, json['d'] as Map<String, dynamic>, guild);
        client.channels.map[channel.id] = channel;
        client.internal.events.onChannelCreate.add(this);
      }
    }
  }
}
