import '../../discord.dart';

/// The options for `Client`.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  bool disableEveryone = false;

  /// The current shard, starting at 0.
  int shardId = 0;

  /// The total number of shards.
  int shardCount = 1;
}
