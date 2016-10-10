part of discord;

/// The options for `Client`.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  bool disableEveryone;

  /// The current shard, starting at 0.
  int shardId;

  /// The total number of shards.
  int shardCount;

  /// The number of messages to cache for each channel.
  int messageCacheSize;

  /// Whether or not to skip events if their object is not cached.
  /// Ex: `onMessageUpdate`.
  bool ignoreUncachedEvents;

  /// A list of discord formatted events to be disabled. Note: some of these events
  /// can be dangerous to disable. Ex: `TYPING_START`
  List<String> disabledEvents;

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.disableEveryone: false,
      this.shardId: 0,
      this.shardCount: 1,
      this.disabledEvents: const [],
      this.messageCacheSize: 200,
      this.ignoreUncachedEvents: true});
}
