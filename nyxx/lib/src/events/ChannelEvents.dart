part of nyxx;

// TODO: Decide what about guild store channels
/// Sent when a channel is created.
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel], [DMChannel], or [GroupDMChannel].
  late final Channel channel;

  ChannelCreateEvent._new(Map<String, dynamic> raw, Nyxx client) {
  
    this.channel = Channel._deserialize(raw, client);

    client.channels[channel.id] = channel;
    if(this.channel is GuildChannel) {
      (this.channel as GuildChannel).guild.channels[channel.id] = channel;
    }
  }
}

/// Sent when a channel is deleted.
class ChannelDeleteEvent {
  /// The channel that was deleted.
  late final Channel channel;

  ChannelDeleteEvent._new(Map<String, dynamic> raw, Nyxx client) {
      var channelSnowflake = Snowflake(raw['d']['id']);
      var channel = client.channels[channelSnowflake];

      if(channel == null) {
        this.channel = Channel._deserialize(raw, client);
      } else {
        this.channel = channel;
      }

      client.channels.remove(channelSnowflake);
      if(this.channel is GuildChannel) {
        (this.channel as GuildChannel).guild.channels.remove(channelSnowflake);
      }
  }
}

/// Fired when channel's pinned messages are updated
class ChannelPinsUpdateEvent {
  /// Channel where pins were updated
  TextChannel? channel;

  /// ID of channel pins were updated
  late final Snowflake channelId;

  /// ID of channels guild
  Snowflake? guildId;

  /// the time at which the most recent pinned message was pinned
 late final DateTime? lastPingTimestamp;

  ChannelPinsUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    if(raw['d']['last_pin_timestamp'] != null) {
      this.lastPingTimestamp = DateTime.parse(raw['d']['last_pin_timestamp'] as String);
    }

    this.channel = client.channels[Snowflake(raw['d']['channel_id'])] as TextChannel;

    if(raw['d']['guild_id'] != null) {
      this.guildId = Snowflake(raw['d']['guild_id']);
    }
  }
}

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel after the update.
  late final Channel updatedChannel;

  ChannelUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.updatedChannel = Channel._deserialize(raw, client);

    client.channels[this.updatedChannel.id] = updatedChannel;

    if(this.updatedChannel is GuildChannel) {
      (this.updatedChannel as GuildChannel).guild.channels[this.updatedChannel.id] = updatedChannel;
    }
  }
}
