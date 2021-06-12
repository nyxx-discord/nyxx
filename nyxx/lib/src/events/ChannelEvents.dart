part of nyxx;

// TODO: Decide what about guild store channels
/// Sent when a channel is created.
class ChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel] or [DMChannel]
  late final IChannel channel;

  ChannelCreateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.channel = IChannel._deserialize(client, raw["d"] as Map<String, dynamic>);

    if (client._cacheOptions.channelCachePolicyLocation.event && client._cacheOptions.channelCachePolicy.canCache(this.channel)) {
      client.channels[this.channel.id] = this.channel;
    }
  }
}

/// Sent when a channel is deleted.
class ChannelDeleteEvent {
  /// The channel that was deleted.
  late final IChannel channel;

  ChannelDeleteEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.channel = IChannel._deserialize(client, raw["d"] as Map<String, dynamic>);

    client.channels.remove(this.channel.id);
  }
}

/// Fired when channel"s pinned messages are updated
class ChannelPinsUpdateEvent {
  /// Channel where pins were updated
  late final CacheableTextChannel<TextChannel> channel;

  /// ID of channel pins were updated
  late final Cacheable<Snowflake, Guild>? guild;

  /// the time at which the most recent pinned message was pinned
  late final DateTime? lastPingTimestamp;

  ChannelPinsUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    if (raw["d"]["last_pin_timestamp"] != null) {
      this.lastPingTimestamp = DateTime.parse(raw["d"]["last_pin_timestamp"] as String);
    }

    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel after the update.
  late final IChannel updatedChannel;

  ChannelUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.updatedChannel = IChannel._deserialize(client, raw["d"] as Map<String, dynamic>);

    final oldChannel = client.channels[this.updatedChannel.id];

    // Move messages to new channel
    if (this.updatedChannel is TextChannel && oldChannel is TextChannel) {
      (this.updatedChannel as TextChannel).messageCache.addMap(oldChannel.messageCache.asMap);
    }

    client.channels[this.updatedChannel.id] = updatedChannel;
  }
}

/// Event for actions related to stage channels
class StageInstanceEvent {
  /// [StageChannelInstance] related to event
  late final StageChannelInstance stageChannelInstance;

  StageInstanceEvent._new(INyxx client, Map<String, dynamic> raw) {
    this.stageChannelInstance = StageChannelInstance._new(client, raw);
  }
}
