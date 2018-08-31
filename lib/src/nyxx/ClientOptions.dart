part of nyxx;

/// The options for [Client]
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  bool disableEveryone;

  /// Whether or not to automatically shard the client if the default shard
  /// values are untouched.
  bool autoShard;

  /// A list of shards for the client to run.
  List<int> shardIds;

  /// The total number of shards.
  int shardCount;

  /// The number of messages to cache for each channel.
  int messageCacheSize;

  /// Whether or not to skip events if their object is not cached.
  /// Ex: `onMessageUpdate`.
  bool ignoreUncachedEvents;

  /// Whether or not to force fetch all of the members the client can see.
  /// Can slow down ready times but is recommended if you rely on `Message.member`
  /// or the member cache.
  bool forceFetchMembers;

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.disableEveryone = false,
      this.autoShard = true,
      this.shardIds = const [0],
      this.shardCount = 1,
      this.messageCacheSize = 200,
      this.ignoreUncachedEvents = true,
      this.forceFetchMembers = false});
}
