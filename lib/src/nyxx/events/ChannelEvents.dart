part of nyxx;

/// Sent when a channel is created.
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel], [DMChannel], or [GroupDMChannel].
  Channel channel;

  ChannelCreateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      if (json['d']['type'] == 1) {
        var tmp = DMChannel._new(json['d'] as Map<String, dynamic>, client);

        client.channels[tmp.id] = tmp;
        this.channel = tmp;
      } else if (json['d']['type'] == 3) {
        var tmp = GroupDMChannel._new(json['d'] as Map<String, dynamic>, client);

        client.channels[tmp.id] = tmp;
        this.channel = tmp;
      } else {
        final Guild guild =
            client.guilds[Snowflake(json['d']['guild_id'] as String)];
        GuildChannel chan;

        if (json['d']['type'] == 0) {
          chan = TextChannel._new(json['d'] as Map<String, dynamic>, guild, client);
        } else if (json['d']['type'] == 2) {
          chan = VoiceChannel._new(json['d'] as Map<String, dynamic>, guild, client);
        } else if (json['d']['type'] == 4) {
          chan = CategoryChannel._new(json['d'] as Map<String, dynamic>, guild, client);
        }

        client.channels[chan.id] = chan;
        guild.channels[chan.id] = chan;
        this.channel = chan;
      }
    }
  }
}

/// Sent when a channel is deleted.
class ChannelDeleteEvent {
  /// The channel that was deleted, either a
  /// [TextChannel], [DMChannel] or [GroupDMChannel] or [VoiceChannel].
  Channel channel;

  ChannelDeleteEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      this.channel = client.channels[Snowflake(json['d']['id'])];

      if(channel is GuildChannel)
        (channel as GuildChannel).guild.channels.remove(channel.id);
    }

    client.channels.remove(channel.id);
  }
}

/// Fired when channel's pinned messages are updated
class ChannelPinsUpdateEvent {
  /// Channel where pins were updated
  TextChannel channel;

  /// the time at which the most recent pinned message was pinned
  DateTime lastPingTimestamp;

  ChannelPinsUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.lastPingTimestamp =
        DateTime.parse(json['d']['last_pin_timestamp'] as String);
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as TextChannel;
  }
}

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  ChannelUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldChannel =
          client.channels[Snowflake(json['d']['id'] as String)] as GuildChannel;

      var type = json['d']['type'] as int;

      if (type == 0) {
        this.newChannel =
            TextChannel._new(json['d'] as Map<String, dynamic>, guild, client);
      } else if (type == 2) {
        this.newChannel =
            VoiceChannel._new(json['d'] as Map<String, dynamic>, guild, client);
      } else if (type == 4) {
        this.newChannel =
            CategoryChannel._new(json['d'] as Map<String, dynamic>, guild, client);
      }

      guild.channels[oldChannel.id] = newChannel;
      client.channels[oldChannel.id] = newChannel;
    }
  }
}
