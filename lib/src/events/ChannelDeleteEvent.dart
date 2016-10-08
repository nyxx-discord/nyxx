part of discord;

/// Sent when a channel is deleted, can be a [PrivateChannel].
class ChannelDeleteEvent {
  /// The channel that was deleted, either a [GuildChannel] or [PrivateChannel].
  dynamic channel;

  /// Constructs a new [ChannelDeleteEvent].
  ChannelDeleteEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new PrivateChannel(client, json['d'] as Map<String, dynamic>);
        client.channels.map.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else {
        final Guild guild = client.guilds.map[json['d']['guild_id']];
        if (json['d']['type'] == 0) {
          this.channel =
              new TextChannel(client, json['d'] as Map<String, dynamic>, guild);
        } else {
          this.channel = new VoiceChannel(
              client, json['d'] as Map<String, dynamic>, guild);
        }
        client.channels.map.remove(channel.id);
        client._events.onChannelDelete.add(this);
      }
    }
  }
}
