import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/src/events/member_chunk_event.dart';
import 'package:nyxx/src/events/raw_event.dart';
import 'package:nyxx/src/internal/connection_manager.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/internal/shard/shard.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';

/// Spawns, connects, monitors, manages and terminates shards.
/// Sharding will be automatic if no user settings are supplied in
/// [ClientOptions] when instantiating [Nyxx] client instance.
///
/// Discord gateways implement a method of user-controlled guild sharding which
/// allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing
/// between separate connections to operate.
abstract class IShardManager implements Disposable {
  /// Emitted when the shard is ready.
  Stream<IShard> get onConnected;

  /// Emitted when the shard encounters a connection error.
  Stream<IShard> get onDisconnect;

  /// Emitted when the shard resumed its connection
  Stream<IShard> get onResume;

  /// Emitted when shard receives member chunk.
  Stream<IMemberChunkEvent> get onMemberChunk;

  /// Raw gateway payloads. You have set `dispatchRawShardEvent` in [ClientOptions] to true otherwise stream won't receive any events.
  /// Also rawEvent is dispatched ONLY for payload that doesn't match any event built in into Nyxx.
  Stream<IRawEvent> get rawEvent;

  /// List of shards
  Iterable<IShard> get shards;

  /// Average gateway latency across all shards
  Duration get gatewayLatency;

  /// The number of identify requests allowed per 5 seconds
  int get maxConcurrency;

  /// Number of shards spawned
  int get numShards;

  /// Sets presences on every shard
  void setPresence(PresenceBuilder presenceBuilder);
}

/// Spawns, connects, monitors, manages and terminates shards.
/// Sharding will be automatic if no user settings are supplied in
/// [ClientOptions] when instantiating [Nyxx] client instance.
///
/// Discord gateways implement a method of user-controlled guild sharding which
/// allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing
/// between separate connections to operate.
class ShardManager implements IShardManager {
  /// Emitted when the shard is ready.
  @override
  late final Stream<IShard> onConnected = this.onConnectController.stream;

  /// Emitted when the shard encounters a connection error.
  @override
  late final Stream<IShard> onDisconnect = this.onDisconnectController.stream;

  /// Emitted when the shard resumed its connection
  @override
  late final Stream<IShard> onResume = this.onDisconnectController.stream;

  /// Emitted when shard receives member chunk.
  @override
  late final Stream<IMemberChunkEvent> onMemberChunk = this.onMemberChunkController.stream;

  /// Raw gateway payloads. You have set `dispatchRawShardEvent` in [ClientOptions] to true otherwise stream won't receive any events.
  /// Also rawEvent is dispatched ONLY for payload that doesn't match any event built in into Nyxx.
  @override
  late final Stream<IRawEvent> rawEvent = this.onRawEventController.stream;

  final StreamController<IShard> onConnectController = StreamController.broadcast();
  final StreamController<IShard> onDisconnectController = StreamController.broadcast();
  final StreamController<IShard> onResumeController = StreamController.broadcast();
  final StreamController<IMemberChunkEvent> onMemberChunkController = StreamController.broadcast();
  final StreamController<IRawEvent> onRawEventController = StreamController.broadcast();

  final Logger logger = Logger("Shard Manager");

  /// List of shards
  @override
  Iterable<Shard> get shards => UnmodifiableListView(this._shards.values);

  /// Average gateway latency across all shards
  @override
  Duration get gatewayLatency =>
      Duration(milliseconds: (this.shards.map((e) => e.gatewayLatency.inMilliseconds).fold<int>(0, (first, second) => first + second)) ~/ shards.length);

  /// The number of identify requests allowed per 5 seconds
  @override
  final int maxConcurrency;

  /// Reference to [ConnectionManager]
  final ConnectionManager connectionManager;

  /// Number of shards spawned
  @override
  late final int numShards;

  final Map<int, Shard> _shards = {};

  Duration get _identifyDelay {
    /// 5s * 1000 / maxConcurrency + 250ms
    final delay = (5 * 1000) ~/ this.maxConcurrency + 300;
    return Duration(milliseconds: delay);
  }

  /// Starts shard manager
  ShardManager(this.connectionManager, this.maxConcurrency) {
    this.numShards = this.connectionManager.client.options.shardCount != null
        ? this.connectionManager.client.options.shardCount!
        : this.connectionManager.recommendedShardsNum;

    if (this.numShards < 1) {
      this.logger.shout("Number of shards cannot be lower than 1.");
      exit(1);
    }

    this.logger.fine("Starting shard manager. Number of shards to spawn: $numShards");
    _connect(numShards - 1);
  }

  /// Sets presences on every shard
  @override
  void setPresence(PresenceBuilder presenceBuilder) {
    for (final shard in shards) {
      shard.setPresence(presenceBuilder);
    }
  }

  void _connect(int shardId) {
    this.logger.fine("Setting up shard with id: $shardId");

    if (shardId < 0) {
      return;
    }

    _shards[shardId] = Shard(shardId, this, connectionManager.gateway);

    Future.delayed(this._identifyDelay, () => _connect(shardId - 1));
  }

  @override
  Future<void> dispose() async {
    this.logger.info("Closing gateway connections...");

    for (final shard in this._shards.values) {
      if (this.connectionManager.client.options.shutdownShardHook != null) {
        this.connectionManager.client.options.shutdownShardHook!(this.connectionManager.client, shard); // ignore: unawaited_futures
      }
      shard.dispose(); // ignore: unawaited_futures
    }

    await this.onConnectController.close();
    await this.onDisconnectController.close();
    await this.onMemberChunkController.close();
  }
}
