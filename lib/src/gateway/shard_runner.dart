import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eterl/eterl.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/gateway/event_parser.dart';
import 'package:nyxx/src/gateway/message.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';

/// An internal class that contains the logic for running a shard.
///
/// This class handles opening the connection, heartbeating and any connection lifecycle events.
class ShardRunner {
  /// The data needed for the shard to operate.
  final ShardData data;

  /// The current heartbeat timer.
  Timer? heartbeatTimer;

  /// The last seq number received.
  int? seq;

  /// The session ID from the latest READY event.
  String? sessionId;

  /// The current active connection.
  ShardConnection? connection;

  /// Whether the last heartbeat was ACKed.
  bool lastHeartbeatAcked = true;

  /// The stopwatch timing the interval between a heartbeat being sent and a heartbeat ACK being received.
  Stopwatch? heartbeatStopwatch;

  /// Whether the current connection can be resumed.
  bool canResume = false;

  /// Whether the shard is currently disposing and should not reconnect.
  bool disposing = false;

  /// The URI to use when connecting to the Gateway.
  late Uri gatewayUri = originalGatewayUri;

  /// The original URI to use when connecting to the Gateway for the first time or after an invalid session.
  late final Uri originalGatewayUri = data.originalConnectionUri.replace(queryParameters: {
    ...data.originalConnectionUri.queryParameters,
    ...data.apiOptions.gatewayConnectionOptions,
  });

  ShardRunner(this.data);

  /// Run the shard runner.
  Stream<ShardMessage> run(Stream<GatewayMessage> messages) async* {
    // Add messages to this controller for them to be sent back to the main isolate.
    final controller = StreamController<ShardMessage>();

    // sendHandler is responsible for handling requests for this shard to send messages to the Gateway.
    // It is paused whenever this shard isn't ready to send messages.
    final sendController = StreamController<Send>();
    // Don't use a tearoff - `connection!` needs to be evaluated every time.
    final sendHandler = sendController.stream.listen((e) => connection!.add(e))..pause();

    // identifyController serves as a notification system for Identify messages.
    // Any Identify messages received are added to this stream.
    final identifyController = StreamController<Identify>.broadcast();

    // startCompleter is completed when the Gateway instance is ready for this shard to start.
    final startCompleter = Completer<StartShard>();

    final messageHandler = messages.listen((message) {
      if (message is Send) {
        sendController.add(message);
      } else if (message is Identify) {
        identifyController.add(message);
      } else if (message is Dispose) {
        disposing = true;
        connection?.close();

        // We might get a dispose request while we are waiting to identify.
        // Add an error to the identify stream so we break out of the wait.
        identifyController.addError(
          Exception('Out of remaining session starts'),
          StackTrace.current,
        );
      } else if (message is StartShard) {
        if (startCompleter.isCompleted) {
          controller.add(ErrorReceived(
            error: StateError('Received StartShard when shard was already started'),
            stackTrace: StackTrace.current,
          ));
        }

        startCompleter.complete(message);
      }
    });

    /// The main connection loop.
    ///
    /// Maintains an active connection until a dispose request is received or the websocket closes with an invalid code.
    Future<void> asyncRun() async {
      while (true) {
        try {
          // Initialize lastHeartbeatAcked to `true` so we don't immediately disconnect in heartbeat().
          lastHeartbeatAcked = true;

          // Pause the send subscription until we are connected.
          if (!sendHandler.isPaused) {
            sendHandler.pause();
          }

          // Open the websocket connection.
          connection = await ShardConnection.connect(gatewayUri.toString(), this);
          connection!.onSent.listen(controller.add);

          // Obtain the heartbeat interval from the HELLO event and start heartbeating.
          final hello = await connection!.first;
          if (hello is! HelloEvent) {
            throw InvalidEventException('Expected HELLO on connection.');
          }
          controller.add(EventReceived(event: hello));

          startHeartbeat(hello.heartbeatInterval);

          // If we can resume (the connection loop was restarted) and we have the information needed, try to resume.
          // Otherwise, identify.
          if (canResume && seq != null && sessionId != null) {
            sendResume();
          } else {
            // Request to identify and wait for the confirmation.
            controller.add(RequestingIdentify());
            await identifyController.stream.first;

            sendIdentify();
          }

          canResume = true;

          // We are connected, start handling send requests.
          sendHandler.resume();

          // Handle events from the connection & forward them to the result controller.
          final subscription = connection!.listen((event) {
            if (event is RawDispatchEvent) {
              seq = event.seq;

              if (event.name == 'READY') {
                final resumeUri = Uri.parse(event.payload['resume_gateway_url'] as String);

                gatewayUri = resumeUri.replace(queryParameters: {
                  ...resumeUri.queryParameters,
                  ...data.apiOptions.gatewayConnectionOptions,
                });

                sessionId = event.payload['session_id'] as String;
              }
            } else if (event is ReconnectEvent) {
              connection!.close(4000);
            } else if (event is InvalidSessionEvent) {
              if (!event.isResumable) {
                canResume = false;
                gatewayUri = originalGatewayUri;
              }

              connection!.close(4000);
            } else if (event is HeartbeatAckEvent) {
              lastHeartbeatAcked = true;
              heartbeatStopwatch = null;
            } else if (event is HeartbeatEvent) {
              connection!.add(Send(opcode: Opcode.heartbeat, data: seq));
            }

            controller.add(EventReceived(event: event));
          });

          // Wait for the current connection to end, either due to a remote close or due to us disconnecting.
          await subscription.asFuture();

          // Check if we can resume based on close code if the connection was closed by Discord.
          if (connection!.localCloseCode == null) {
            // https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
            const resumableCodes = [null, 4000, 4001, 4002, 4003, 4005, 4008];
            const errorCodes = [4004, 4010, 4011, 4012, 4013, 4014];

            if (errorCodes.contains(connection!.remoteCloseCode)) {
              controller.add(Disconnecting(reason: 'Received error close code: ${connection!.remoteCloseCode}'));
              return;
            }

            canResume = resumableCodes.contains(connection!.remoteCloseCode);

            controller.add(ErrorReceived(
              error: 'Connection was closed with code ${connection!.remoteCloseCode}',
              stackTrace: StackTrace.current,
            ));
          }
        } catch (error, stackTrace) {
          controller.add(ErrorReceived(error: error, stackTrace: stackTrace));
          // Prevents the while-true loop from looping too often when no internet is available.
          await Future.delayed(Duration(milliseconds: 100));
        } finally {
          // Reset connection properties.
          await connection?.close(4000);
          connection = null;
          heartbeatTimer?.cancel();
          heartbeatTimer = null;
          heartbeatStopwatch = null;
        }

        // Check for dispose requests. If we should be disposing, exit the loop.
        if (disposing) {
          controller.add(Disconnecting(reason: 'Dispose requested'));
          return;
        }
      }
    }

    await startCompleter.future;
    asyncRun().then((_) {
      controller.close();
      sendController.close();
      identifyController.close();
      messageHandler.cancel();
    });

    yield* controller.stream;
  }

  void heartbeat() {
    if (!lastHeartbeatAcked) {
      connection!.close(4000);
      return;
    }

    connection!.add(Send(opcode: Opcode.heartbeat, data: seq));
    lastHeartbeatAcked = false;
  }

  void startHeartbeat(Duration heartbeatInterval) {
    heartbeatTimer = Timer(heartbeatInterval * Random().nextDouble(), () {
      heartbeat();

      heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => heartbeat());
    });
  }

  void sendIdentify() {
    connection!.add(Send(
      opcode: Opcode.identify,
      data: {
        'token': data.apiOptions.token,
        'properties': {
          'os': Platform.operatingSystem,
          'browser': 'nyxx',
          'device': 'nyxx',
        },
        if (data.apiOptions.compression == GatewayCompression.payload) 'compress': true,
        if (data.apiOptions.largeThreshold != null) 'large_threshold': data.apiOptions.largeThreshold,
        'shard': [data.id, data.totalShards],
        if (data.apiOptions.initialPresence != null) 'presence': data.apiOptions.initialPresence!.build(),
        'intents': data.apiOptions.intents.value,
      },
    ));
  }

  void sendResume() {
    assert(sessionId != null && seq != null);
    connection!.add(Send(
      opcode: Opcode.resume,
      data: {
        'token': data.apiOptions.token,
        'session_id': sessionId,
        'seq': seq,
      },
    ));
  }
}

class ShardConnection extends Stream<GatewayEvent> implements StreamSink<Send> {
  final WebSocket websocket;
  final Stream<GatewayEvent> events;
  final ShardRunner runner;

  int? localCloseCode;
  int? get remoteCloseCode => localCloseCode == null ? websocket.closeCode : null;

  final StreamController<Sent> _sentController = StreamController();
  Stream<Sent> get onSent => _sentController.stream;

  ShardConnection(this.websocket, this.events, this.runner);

  static Future<ShardConnection> connect(String gatewayUri, ShardRunner runner) async {
    final connection = await WebSocket.connect(gatewayUri);

    final uncompressedStream = switch (runner.data.apiOptions.compression) {
      GatewayCompression.transport => decompressTransport(connection.cast<List<int>>()),
      GatewayCompression.payload => decompressPayloads(connection),
      GatewayCompression.none => connection,
    };

    final dataStream = switch (runner.data.apiOptions.payloadFormat) {
      GatewayPayloadFormat.json => parseJson(uncompressedStream),
      GatewayPayloadFormat.etf => parseEtf(uncompressedStream.cast<List<int>>()),
    };

    final parser = EventParser();
    final eventStream =
        dataStream.cast<Map<String, Object?>>().map((event) => parser.parseGatewayEvent(event, heartbeatLatency: runner.heartbeatStopwatch?.elapsed));

    return ShardConnection(connection, eventStream.asBroadcastStream(), runner);
  }

  @override
  StreamSubscription<GatewayEvent> listen(
    void Function(GatewayEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return events.listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
  }

  @override
  void add(Send event) {
    final payload = {
      'op': event.opcode.value,
      'd': event.data,
    };

    final encoded = switch (runner.data.apiOptions.payloadFormat) {
      GatewayPayloadFormat.json => jsonEncode(payload),
      GatewayPayloadFormat.etf => eterl.pack(payload),
    };

    if (event.opcode == Opcode.heartbeat) {
      runner.heartbeatStopwatch = Stopwatch()..start();
    }

    websocket.add(encoded);
    _sentController.add(Sent(payload: event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) => websocket.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<Send> stream) => stream.forEach(add);

  @override
  Future<void> close([int code = 1000]) async {
    localCloseCode = code;
    await websocket.close(code);
    await _sentController.close();
  }

  @override
  Future<void> get done => websocket.done.then((_) => _sentController.done);
}

Stream<dynamic> decompressTransport(Stream<List<int>> raw) {
  final filter = RawZLibFilter.inflateFilter();

  return raw.map((chunk) {
    filter.process(chunk, 0, chunk.length);

    final buffer = <int>[];
    for (List<int>? decoded = []; decoded != null; decoded = filter.processed()) {
      buffer.addAll(decoded);
    }

    return buffer;
  });
}

Stream<dynamic> decompressPayloads(Stream<dynamic> raw) => raw.map((message) {
      if (message is String) {
        return message;
      } else {
        return zlib.decode(message as List<int>);
      }
    });

Stream<dynamic> parseJson(Stream<dynamic> raw) => raw.map((message) {
      final source = message is String ? message : utf8.decode(message as List<int>);

      return jsonDecode(source);
    });

Stream<dynamic> parseEtf(Stream<List<int>> raw) => raw.transform(eterl.unpacker());
