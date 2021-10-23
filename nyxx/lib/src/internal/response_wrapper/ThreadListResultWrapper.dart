part of nyxx;

/// Wrapper of threads listing results.
class ThreadListResultWrapper implements IThreadListResultWrapper {
  /// List of threads
  late final List<IThreadChannel> threads;

  /// A thread member object for each returned thread the current user has joined
  late final List<IThreadMember> selfThreadMembers;

  /// Whether there are potentially additional threads that could be returned on a subsequent call
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
