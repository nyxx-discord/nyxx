import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/gateway/event_parser.dart';
import 'package:nyxx/src/gateway/message.dart';
import 'package:nyxx/src/gateway/shard.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';
import 'package:nyxx/src/models/events/event.dart';
import 'package:nyxx/src/models/events/guild.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';

/// Handles the connection to Discord's Gateway with shards, manages the client's cache based on Gateway events and provides an interface to the Gateway.
class Gateway extends GatewayManager with EventParser {
  @override
  final NyxxGateway client;

  /// The [GatewayBot] instance used to configure this [Gateway].
  final GatewayBot gatewayBot;

  /// The total number of shards running in the client's session.
  final int totalShards;

  /// The IDs of the shards running in this [Gateway].
  final List<int> shardIds;

  /// The shards running in this [Gateway].
  final List<Shard> shards;

  /// A stream of messages received from all shards.
  // Adapting _messagesController.stream to a broadcast stream instead of
  // simply making _messagesController a broadcast controller means events will
  // be buffered until this field is initialized, which prevents events from
  // being dropped during the connection process.
  late final Stream<ShardMessage> messages = _messagesController.stream.asBroadcastStream();

  final StreamController<ShardMessage> _messagesController = StreamController();

  /// A stream of dispatch events received from all shards.
  // Make this late instead of a getter so only a single subscription is made, which prevents events from being parsed multiple times.
  late final Stream<DispatchEvent> events = messages.transform(StreamTransformer.fromBind((messages) async* {
    await for (final message in messages) {
      if (message is! EventReceived) continue;

      final event = message.event;
      if (event is! RawDispatchEvent) continue;

      final parsedEvent = parseDispatchEvent(event, client);
      // Update the cache as needed.
      client.updateCacheWith(parsedEvent);
      yield parsedEvent;
    }
  })).asBroadcastStream();

  bool _closing = false;

  /// The average latency across all shards in this [Gateway].
  ///
  /// See [Shard.latency] for details on how the latency is calculated.
  Duration get latency => shards.fold(Duration.zero, (previousValue, element) => previousValue + (element.latency ~/ shards.length));

  final Set<Timer> _startOrIdentifyTimers = {};

  /// Create a new [Gateway].
  Gateway(this.client, this.gatewayBot, this.shards, this.totalShards, this.shardIds) : super.create() {
    final logger = Logger('${client.options.loggerName}.Gateway');

    // https://discord.com/developers/docs/topics/gateway#rate-limiting
    const identifyDelay = Duration(seconds: 5);
    final maxConcurrency = gatewayBot.sessionStartLimit.maxConcurrency;
    var remainingIdentifyRequests = gatewayBot.sessionStartLimit.remaining;

    // A mapping of rateLimitId (shard.id % maxConcurrency) to Futures that complete when the identify lock for that rate_limit_key is no longer used.
    final identifyLocks = <int, Future<void>>{};

    // Handle messages from the shards and start them according to their rate limit key.
    for (final shard in shards) {
      final rateLimitKey = shard.id % maxConcurrency;

      // Delay the shard starting until it is (approximately) also ready to identify.
      // This avoids opening many websocket connections simultaneously just to have most
      // of them wait for their identify request.
      late final Timer startTimer;
      startTimer = Timer(identifyDelay * (shard.id ~/ maxConcurrency), () {
        logger.fine('Starting shard ${shard.id}');
        shard.add(StartShard());
        _startOrIdentifyTimers.remove(startTimer);
      });
      _startOrIdentifyTimers.add(startTimer);

      shard.listen(
        (event) {
          _messagesController.add(event);

          if (event is RequestingIdentify) {
            final currentLock = identifyLocks[rateLimitKey] ?? Future.value();
            identifyLocks[rateLimitKey] = currentLock.then((_) async {
              if (_closing) return;

              if (remainingIdentifyRequests < client.options.minimumSessionStarts * 5) {
                logger.warning('$remainingIdentifyRequests session starts remaining');
              }

              if (remainingIdentifyRequests < client.options.minimumSessionStarts) {
                await client.close();
                throw OutOfRemainingSessionsError(gatewayBot);
              }

              remainingIdentifyRequests--;
              shard.add(Identify());

              // Don't use Future.delayed so that we can exit early if close() is called.
              // If we use Future.delayed, the program will remain alive until it is complete, even if nothing is waiting on it.
              // This code is roughly equivalent to `await Future.delayed(identifyDelay)`
              final delayCompleter = Completer<void>();
              final delayTimer = Timer(identifyDelay, delayCompleter.complete);
              _startOrIdentifyTimers.add(delayTimer);
              await delayCompleter.future;
              _startOrIdentifyTimers.remove(delayTimer);
            });
          }
        },
        onError: _messagesController.addError,
        onDone: () async {
          if (_closing) {
            return;
          }

          await client.close();

          throw ShardDisconnectedError(shard);
        },
        cancelOnError: false,
      );
    }
  }

  /// Connect to the gateway using the provided [client] and [gatewayBot] configuration.
  static Future<Gateway> connect(NyxxGateway client, GatewayBot gatewayBot) async {
    final logger = Logger('${client.options.loggerName}.Gateway');

    final totalShards = client.apiOptions.totalShards ?? gatewayBot.shards;
    final List<int> shardIds = client.apiOptions.shards ?? List.generate(totalShards, (i) => i);

    logger
      ..info('Connecting ${shardIds.length}/$totalShards shards')
      ..fine('Shard IDs: $shardIds')
      ..fine(
        'Gateway URL: ${gatewayBot.url}, Recommended Shards: ${gatewayBot.shards}, Max Concurrency: ${gatewayBot.sessionStartLimit.maxConcurrency},'
        ' Remaining Session Starts: ${gatewayBot.sessionStartLimit.remaining}, Reset After: ${gatewayBot.sessionStartLimit.resetAfter}',
      );

    assert(
      shardIds.every((element) => element < totalShards),
      'Shard ID exceeds total shard count',
    );

    assert(
      shardIds.every((element) => element >= 0),
      'Invalid shard ID',
    );

    assert(
      shardIds.toSet().length == shardIds.length,
      'Duplicate shard ID',
    );

    assert(
      client.apiOptions.compression != GatewayCompression.payload || client.apiOptions.payloadFormat != GatewayPayloadFormat.etf,
      'Cannot enable payload compression when using the ETF payload format',
    );

    final shards = shardIds.map((id) => Shard.connect(id, totalShards, client.apiOptions, gatewayBot.url, client));
    return Gateway(client, gatewayBot, await Future.wait(shards), totalShards, shardIds);
  }

  /// Close this [Gateway] instance, disconnecting all shards and closing the event streams.
  Future<void> close() async {
    _closing = true;
    // Make sure we don't start any shards after we have closed.
    for (final timer in _startOrIdentifyTimers) {
      timer.cancel();
    }
    await Future.wait(shards.map((shard) => shard.close()));
    _messagesController.close();
  }

  /// Compute the ID of the shard that handles events for [guildId].
  int shardIdFor(Snowflake guildId) => (guildId.value >> 22) % totalShards;

  /// Return the shard that handles events for [guildId].
  ///
  /// Throws an error if the shard handling events for [guildId] is not in this [Gateway] instance.
  Shard shardFor(Snowflake guildId) => shards.singleWhere((shard) => shard.id == shardIdFor(guildId));

  /// Stream all members in a guild that match [query] or [userIds].
  ///
  /// If neither is provided, all members in the guild are returned.
  Stream<Member> listGuildMembers(
    Snowflake guildId, {
    String? query,
    int? limit,
    List<Snowflake>? userIds,
    bool? includePresences,
    String? nonce,
  }) async* {
    if (userIds == null) {
      query ??= '';
    }

    limit ??= 0;
    nonce ??= '${Snowflake.now().value.toRadixString(36)}${guildId.value.toRadixString(36)}';

    final shard = shardFor(guildId);
    shard.add(Send(opcode: Opcode.requestGuildMembers, data: {
      'guild_id': guildId.toString(),
      if (query != null) 'query': query,
      'limit': limit,
      if (includePresences != null) 'presences': includePresences,
      if (userIds != null) 'user_ids': userIds.map((e) => e.toString()).toList(),
      'nonce': nonce,
    }));

    int chunksReceived = 0;

    await for (final event in events) {
      if (event is! GuildMembersChunkEvent || event.nonce != nonce) {
        continue;
      }

      yield* Stream.fromIterable(event.members);

      chunksReceived++;
      if (chunksReceived == event.chunkCount) {
        break;
      }
    }
  }

  /// Update the client's voice state in the guild with ID [guildId].
  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) => shardFor(guildId).updateVoiceState(guildId, builder);

  /// Update the client's presence on all shards.
  void updatePresence(PresenceBuilder builder) {
    for (final shard in shards) {
      shard.add(Send(opcode: Opcode.presenceUpdate, data: builder.build()));
    }
  }
}
