part of nyxx;

/// Sent when a channel is created.
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel], [DMChannel], or [GroupDMChannel].
  Channel channel;

  ChannelCreateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        var tmp = DMChannel._new(json['d'] as Map<String, dynamic>);

        client.channels[tmp.id] = tmp;
        this.channel = tmp;

        client._events.onChannelCreate.add(this);
      } else if (json['d']['type'] == 3) {
        var tmp = GroupDMChannel._new(json['d'] as Map<String, dynamic>);

        client.channels[tmp.id] = tmp;
        this.channel = tmp;
      } else {
        final Guild guild =
            client.guilds[Snowflake(json['d']['guild_id'] as String)];
        GuildChannel chan;

        if (json['d']['type'] == 0) {
          chan = TextChannel._new(json['d'] as Map<String, dynamic>, guild);
        } else if (json['d']['type'] == 2) {
          chan = VoiceChannel._new(json['d'] as Map<String, dynamic>, guild);
        } else if (json['d']['type'] == 4) {
          chan = GroupChannel._new(json['d'] as Map<String, dynamic>, guild);
        }

        client.channels[chan.id] = chan;
        guild.channels[chan.id] = chan;
        this.channel = chan;
      }
    }

    client._events.onChannelCreate.add(this);
  }
}
