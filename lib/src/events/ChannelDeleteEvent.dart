part of nyxx;

/// Sent when a channel is deleted.
class ChannelDeleteEvent {
  /// The channel that was deleted, either a [GuildChannel], [DMChannel] or [GroupDMChannel].
  dynamic channel;

  ChannelDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new DMChannel._new(client, json['d'] as Map<String, dynamic>);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else if (json['d']['type'] == 3) {
        this.channel =
            new GroupDMChannel._new(client, json['d'] as Map<String, dynamic>);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      } else {
        final Guild guild = client.guilds[json['d']['guild_id']];
        if (json['d']['type'] == 0) {
          this.channel = new TextChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        } else {
          this.channel = new VoiceChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        }
        guild.channels.remove(channel.id);
        client.channels.remove(channel.id);
        client._events.onChannelDelete.add(this);
      }
    }
  }
}
