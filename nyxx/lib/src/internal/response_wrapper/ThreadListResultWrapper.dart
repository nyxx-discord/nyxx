part of nyxx;

class ThreadListResultWrapper {
  /// List of threads
  late final List<ThreadChannel> threads;

  /// A thread member object for each returned thread the current user has joined
  late final List<ThreadMember> selfThreadMembers;

  /// Whether there are potentially additional threads that could be returned on a subsequent call
  late final bool hasMore;

  ThreadListResultWrapper._new(INyxx client, RawApiMap raw) {
    this.threads = [
      for (final rawThread in raw["threads"])
        ThreadChannel._new(client, rawThread as RawApiMap)
    ];

    this.selfThreadMembers = [
      for (final rawMember in raw["members"])
        ThreadMember._new(
            client,
            rawMember as RawApiMap,
            _ChannelCacheable(client, this.threads.firstWhere((element) => element.id == rawMember["id"]).id)
        )
    ];

    this.hasMore = raw["has_more"] as bool;
  }
}
