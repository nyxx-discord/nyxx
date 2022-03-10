import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/guild/voice_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel] or [DMChannel]
  IChannel get channel;
}

/// Sent when a channel is created.
class ChannelCreateEvent implements IChannelCreateEvent {
  /// The channel that was created, either a [GuildChannel] or [DMChannel]
  @override
  late final IChannel channel;

  /// Creates an instance of [ChannelCreateEvent]
  ChannelCreateEvent(RawApiMap raw, INyxx client) {
    channel = Channel.deserialize(client, raw["d"] as RawApiMap);

    if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(channel)) {
      client.channels[channel.id] = channel;
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
  @override
  late final IChannel channel;

  /// Creates an instance of [ChannelDeleteEvent]
  ChannelDeleteEvent(RawApiMap raw, INyxx client) {
    channel = Channel.deserialize(client, raw["d"] as RawApiMap);

    client.channels.remove(channel.id);
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
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// ID of channel pins were updated
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// the time at which the most recent pinned message was pinned
  @override
  late final DateTime? lastPingTimestamp;

  /// Creates na instance of [ChannelPinsUpdateEvent]
  ChannelPinsUpdateEvent(RawApiMap raw, INyxx client) {
    if (raw["d"]["last_pin_timestamp"] != null) {
      lastPingTimestamp = DateTime.parse(raw["d"]["last_pin_timestamp"] as String);
    }

    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      guild = null;
    }
  }
}

abstract class IChannelUpdateEvent {
  /// The channel after the update.
  IChannel get updatedChannel;

  /// The channel before the update, if it was cached.
  IChannel? get oldChannel;
}

/// Sent when a channel is updated.
class ChannelUpdateEvent implements IChannelUpdateEvent {
  /// The channel after the update.
  @override
  late final IChannel updatedChannel;

  @override
  late final IChannel? oldChannel;

  /// Creates na instance of [ChannelUpdateEvent]
  ChannelUpdateEvent(RawApiMap raw, INyxx client) {
    updatedChannel = Channel.deserialize(client, raw["d"] as RawApiMap);

    oldChannel = client.channels[updatedChannel.id];

    // Move messages to new channel
    if (updatedChannel is ITextChannel && oldChannel is ITextChannel) {
      (updatedChannel as ITextChannel).messageCache.addAll((oldChannel as ITextChannel).messageCache);
    }

    client.channels[updatedChannel.id] = updatedChannel;
  }
}

abstract class IStageInstanceEvent {
  /// [IStageChannelInstance] related to event
  IStageChannelInstance get stageChannelInstance;
}

/// Event for actions related to stage channels
class StageInstanceEvent implements IStageInstanceEvent {
  /// [IStageChannelInstance] related to event
  @override
  late final IStageChannelInstance stageChannelInstance;

  /// Creates na instance of [StageInstanceEvent]
  StageInstanceEvent(INyxx client, RawApiMap raw) {
    stageChannelInstance = StageChannelInstance(client, raw);
  }
}
