import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IThreadListResultWrapper {
  /// List of threads
  List<IThreadChannel> get threads;

  /// A thread member object for each returned thread the current user has joined
  List<IThreadMember> get selfThreadMembers;

  /// Whether there are potentially additional threads that could be returned on a subsequent call
  bool get hasMore;
}

/// Wrapper of threads listing results.
class ThreadListResultWrapper implements IThreadListResultWrapper {
  /// List of threads
  @override
  late final List<IThreadChannel> threads;

  /// A thread member object for each returned thread the current user has joined
  @override
  late final List<IThreadMember> selfThreadMembers;

  /// Whether there are potentially additional threads that could be returned on a subsequent call
  @override
  late final bool hasMore;

  /// Create an instance of [ThreadListResultWrapper]
  ThreadListResultWrapper(INyxx client, RawApiMap raw) {
    threads = [for (final rawThread in raw["threads"] as RawApiList) ThreadChannel(client, rawThread as RawApiMap)];

    selfThreadMembers = [
      for (final rawMember in raw["members"] as RawApiList)
        ThreadMember(client, rawMember as RawApiMap, ChannelCacheable(client, threads.firstWhere((element) => element.id == rawMember["id"]).id))
    ];

    hasMore = raw["has_more"] as bool;
  }
}
