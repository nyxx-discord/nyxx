part of nyxx;

/// Sent when a channel is deleted.
class ChannelDeleteEvent {
  /// The channel that was deleted, either a
  /// [TextChannel], [DMChannel] or [GroupDMChannel] or [VoiceChannel].
  Channel channel;

  ChannelDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            DMChannel._new(client, json['d'] as Map<String, dynamic>);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else if (json['d']['type'] == 3) {
        this.channel =
            GroupDMChannel._new(client, json['d'] as Map<String, dynamic>);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else {
        final Guild guild =
            client.guilds[Snowflake(json['d']['guild_id'] as String)];
        if (json['d']['type'] == 0) {
          this.channel = TextChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        } else {
          this.channel = VoiceChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        }
        guild.channels.remove(channel.id);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      }
    }
  }
}
