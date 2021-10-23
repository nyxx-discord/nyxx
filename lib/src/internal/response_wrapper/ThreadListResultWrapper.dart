import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
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
    this.threads = [
      for (final rawThread in raw["threads"])
        ThreadChannel(client, rawThread as RawApiMap)
    ];

    this.selfThreadMembers = [
      for (final rawMember in raw["members"])
        ThreadMember(
            client,
            rawMember as RawApiMap,
            ChannelCacheable(client, this.threads.firstWhere((element) => element.id == rawMember["id"]).id)
        )
    ];

    this.hasMore = raw["has_more"] as bool;
  }
}
