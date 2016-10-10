part of discord;

/// Sent when a channel is deleted, can be a [PrivateChannel].
class ChannelDeleteEvent {
  /// The channel that was deleted, either a [GuildChannel] or [PrivateChannel].
  dynamic channel;

  ChannelDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new PrivateChannel._new(client, json['d'] as Map<String, dynamic>);
        client.channels.map.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else {
        final Guild guild = client.guilds.map[json['d']['guild_id']];
        if (json['d']['type'] == 0) {
          this.channel = new TextChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        } else {
          this.channel = new VoiceChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        }
        guild.channels.map.remove(channel.id);
        client.channels.map.remove(channel.id);
        client._events.onChannelDelete.add(this);
      }
    }
  }
}
