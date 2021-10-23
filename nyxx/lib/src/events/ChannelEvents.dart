part of nyxx;

// TODO: Decide what about guild store channels
/// Sent when a channel is created.
class ChannelCreateEvent implements IChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel] or [DMChannel]
  late final IChannel channel;

  /// Creates an instance of [ChannelCreateEvent]
  ChannelCreateEvent(RawApiMap raw, INyxx client) {
    this.channel = Channel.deserialize(client, raw["d"] as RawApiMap);

    if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(this.channel)) {
      client.channels[this.channel.id] = this.channel;
    }
  }
}

/// Sent when a channel is deleted.
abstract class IChannelDeleteEvent {
  /// The channel that was deleted.
  IChannel get channel;
}

/// Sent when a channel is deleted.
class ChannelDeleteEvent implements IChannelDeleteEvent {
  /// The channel that was deleted.
  late final IChannel channel;

  /// Creates an instance of [ChannelDeleteEvent]
  ChannelDeleteEvent(RawApiMap raw, INyxx client) {
    this.channel = Channel.deserialize(client, raw["d"] as RawApiMap);

    client.channels.remove(this.channel.id);
  }
}

abstract class IChannelPinsUpdateEvent {
  /// Channel where pins were updated
  late final CacheableTextChannel<ITextChannel> channel;

  /// ID of channel pins were updated
  late final Cacheable<Snowflake, IGuild>? guild;

  /// the time at which the most recent pinned message was pinned
  late final DateTime? lastPingTimestamp;
}

/// Fired when channel"s pinned messages are updated
class ChannelPinsUpdateEvent implements IChannelPinsUpdateEvent {
  /// Channel where pins were updated
  late final CacheableTextChannel<ITextChannel> channel;

  /// ID of channel pins were updated
  late final Cacheable<Snowflake, IGuild>? guild;

  /// the time at which the most recent pinned message was pinned
  late final DateTime? lastPingTimestamp;

  /// Creates na instance of [ChannelPinsUpdateEvent]
  ChannelPinsUpdateEvent(RawApiMap raw, INyxx client) {
    if (raw["d"]["last_pin_timestamp"] != null) {
      this.lastPingTimestamp = DateTime.parse(raw["d"]["last_pin_timestamp"] as String);
    }

    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}

abstract class IChannelUpdateEvent {
  /// The channel after the update.
  IChannel get updatedChannel;
}

/// Sent when a channel is updated.
class ChannelUpdateEvent implements IChannelUpdateEvent {
  /// The channel after the update.
  late final IChannel updatedChannel;

  /// Creates na instance of [ChannelUpdateEvent]
  ChannelUpdateEvent(RawApiMap raw, INyxx client) {
    this.updatedChannel = Channel.deserialize(client, raw["d"] as RawApiMap);

    final oldChannel = client.channels[this.updatedChannel.id];

    // Move messages to new channel
    if (this.updatedChannel is ITextChannel && oldChannel is ITextChannel) {
      (this.updatedChannel as ITextChannel).messageCache.addAll(oldChannel.messageCache);
    }

    client.channels[this.updatedChannel.id] = updatedChannel;
  }
}

abstract class IStageInstanceEvent {
  /// [IStageChannelInstance] related to event
  IStageChannelInstance get stageChannelInstance;
}

/// Event for actions related to stage channels
class StageInstanceEvent implements IStageInstanceEvent {
  /// [IStageChannelInstance] related to event
  late final IStageChannelInstance stageChannelInstance;

  /// Creates na instance of [StageInstanceEvent]
  StageInstanceEvent(INyxx client, RawApiMap raw) {
    this.stageChannelInstance = StageChannelInstance(client, raw);
  }
}
