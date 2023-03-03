import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IThreadListSyncEvent {
  /// The guild being synced.
  Cacheable<Snowflake, IGuild> get guild;

  /// A list of channels which are the parents of the threads being synced.
  List<Cacheable<Snowflake, ITextChannel>> get channels;

  /// The threads being synced.
  List<IThreadChannel> get threads;

  /// The thread members being synced.
  List<IThreadMember> get threadMembers;
}

class ThreadListSyncEvent implements IThreadListSyncEvent {
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  @override
  late final List<Cacheable<Snowflake, ITextChannel>> channels;

  @override
  late final List<IThreadChannel> threads;

  @override
  late final List<IThreadMember> threadMembers;

  ThreadListSyncEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw['guild_id']));
    channels = [
      for (final channelId in (raw['channel_ids'] ?? []) as RawApiList) ChannelCacheable(client, Snowflake(channelId)),
    ];

    threads = [
      for (final rawThread in raw['threads'] as RawApiList) ThreadChannel(client, rawThread as RawApiMap),
    ];

    for (final thread in threads) {
      if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(thread)) {
        client.channels[thread.id] = thread;
      }
    }

    threadMembers = [
      for (final rawMember in raw['members'] as RawApiList) ThreadMember(client, rawMember as RawApiMap, guild),
    ];
  }
}
