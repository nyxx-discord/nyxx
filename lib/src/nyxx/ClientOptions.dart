part of nyxx;

/// Optional client settings which can be used when creating new instance
/// of client. It allows to tune up client to your needs.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  /// **It means client won't send any of these. It doesn't mean filtering guild messages.**
  bool disableEveryone;

  /// The index of this shard
  int shardIndex;

  /// The total number of shards.
  int shardCount;

  /// The number of messages to cache for each channel.
  int messageCacheSize;

  /// Whether or not to force fetch all of the members the client can see.
  /// Can slow down ready times but is recommended if you rely on `Message.member`
  /// or the member cache.
  bool forceFetchMembers;

  /// Allows to disable member caching on `GUILD_CREATE` event.
  /// **It means client will collect members from other events**
  bool cacheMembers;

  int largeThreshold;

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.disableEveryone = false,
      this.shardIndex = 0,
      this.shardCount = 1,
      this.messageCacheSize = 400,
      this.forceFetchMembers = false,
      this.cacheMembers = true,
      this.largeThreshold = 50});
}
