part of discord;

/// The options for `Client`.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  bool disableEveryone;

  /// The current shard, starting at 0.
  int shardId;

  /// The total number of shards.
  int shardCount;

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.disableEveryone: false, this.shardId: 0, this.shardCount: 1});
}
