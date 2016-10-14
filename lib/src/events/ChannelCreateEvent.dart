part of discord;

/// Sent when a channel is created..
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel], [DMChannel], or [GroupDMChannel].
  dynamic channel;

  ChannelCreateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        this.channel =
            new DMChannel._new(client, json['d'] as Map<String, dynamic>);
        client._events.onChannelCreate.add(this);
      } else if (json['d']['type'] == 3) {
        this.channel =
            new GroupDMChannel._new(client, json['d'] as Map<String, dynamic>);
        client._events.onChannelCreate.add(this);
      } else {
        final Guild guild = client.guilds.map[json['d']['guild_id']];
        if (json['d']['type'] == 0) {
          this.channel = new TextChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        } else {
          this.channel = new VoiceChannel._new(
              client, json['d'] as Map<String, dynamic>, guild);
        }
        client._events.onChannelCreate.add(this);
      }
    }
  }
}
