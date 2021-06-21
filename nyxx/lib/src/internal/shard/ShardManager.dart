part of nyxx;

/// Spawns, connects, monitors, manages and terminates shards.
/// Sharding will be automatic if no user settings are supplied in
/// [ClientOptions] when instantiating [Nyxx] client instance.
///
/// Discord gateways implement a method of user-controlled guild sharding which
/// allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing
/// between separate connections to operate.
class ShardManager implements Disposable {
  /// Emitted when the shard is ready.
  late final Stream<Shard> onConnected = this._onConnect.stream;

  /// Emitted when the shard encounters a connection error.
  late final Stream<Shard> onDisconnect = this._onDisconnect.stream;

  /// Emitted when shard receives member chunk.
  late final Stream<MemberChunkEvent> onMemberChunk = this._onMemberChunk.stream;

  /// Raw gateway payloads. You have set `dispatchRawShardEvent` in [ClientOptions] to true otherwise stream won't receive any events.
  /// Also rawEvent is dispatched ONLY for payload that doesn't match any event built in into Nyxx.
  late final Stream<RawEvent> rawEvent = this._onRawEvent.stream;

  final StreamController<Shard> _onConnect = StreamController.broadcast();
  final StreamController<Shard> _onDisconnect = StreamController.broadcast();
  final StreamController<MemberChunkEvent> _onMemberChunk = StreamController.broadcast();
  final StreamController<RawEvent> _onRawEvent = StreamController.broadcast();

  final Logger _logger = Logger("Shard Manager");

  /// List of shards
  Iterable<Shard> get shards => UnmodifiableListView(this._shards.values);

  /// Average gateway latency across all shards
  Duration get gatewayLatency
    => Duration(milliseconds: (this.shards.map((e) => e.gatewayLatency.inMilliseconds)
        .fold<int>(0, (first, second) => first + second)) ~/ shards.length);

  /// The number of identify requests allowed per 5 seconds
  final int maxConcurrency;
  final _ConnectionManager _ws;
  late final int _numShards;
  final Map<int, Shard> _shards = {};

  Duration get _identifyDelay {
    /// 5s * 1000 / maxConcurrency + 250ms
    final delay = (5 * 1000) ~/ this.maxConcurrency + 250;
    return Duration(milliseconds: delay);
  }

  /// Starts shard manager
  ShardManager._new(this._ws, this.maxConcurrency) {
    this._numShards = this._ws._client._options.shardCount != null ? this._ws._client._options.shardCount! : this._ws.recommendedShardsNum;

    if (this._numShards < 1) {
      this._logger.shout("Number of shards cannot be lower than 1.");
      exit(1);
    }

    _connect(_numShards - 1);
  }

  /// Sets presences on every shard
  void setPresence(PresenceBuilder presenceBuilder) {
    for (final shard in shards) {
      shard.setPresence(presenceBuilder);
    }
  }

  void _connect(int shardId) {
    if(shardId < 0) {
      return;
    }

    final shard = Shard._new(shardId, this, _ws.gateway);
    _shards[shardId] = shard;

    Future.delayed(this._identifyDelay, () => _connect(shardId - 1));
  }

  @override
  Future<void> dispose() async {
    this._logger.info("Closing gateway connections...");

    for(final shard in this._shards.values) {
      if(this._ws._client._options.shutdownShardHook != null) {
        this._ws._client._options.shutdownShardHook!(this._ws._client, shard); // ignore: unawaited_futures
      }
      shard.dispose(); // ignore: unawaited_futures
    }

    await this._onConnect.close();
    await this._onDisconnect.close();
    await this._onMemberChunk.close();
  }
}
