import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:eterl/eterl.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/internal/shard/message.dart';
import 'package:nyxx/src/typedefs.dart';

void shardHandler(SendPort sendPort) {
  final runner = ShardRunner(sendPort);

  sendPort.send(runner.receivePort.sendPort);
}

class ShardRunner implements Disposable {
  /// The receive port on which messages from the manager will be received.
  final ReceivePort receivePort = ReceivePort();

  /// A stream on which messages from the manager will be received.
  Stream<ShardMessage<ManagerToShard>> get managerMessages => receivePort.cast<ShardMessage<ManagerToShard>>();

  /// The send port on which messages to the manager should be added;
  final SendPort sendPort;

  /// The current active connection.
  WebSocket? connection;

  /// The subscription to the current active connection.
  StreamSubscription<dynamic>? connectionSubscription;

  /// Whether this shard is currently connected to Discord.
  bool get connected => connection?.readyState == WebSocket.open;

  /// Whether this shard is currently reconnecting.
  ///
  /// [ShardToManager.disconnected] will not be dispatched if this is true.
  bool reconnecting = false;

  /// Whether this shard is currently disposing itself.
  ///
  /// [ShardToManager.disconnected] will not be dispatched if this is true.
  bool disposing = false;

  /// Whether this shard is currently connecting to the gateway.
  bool connecting = false;

  /// The last sequence number
  // Start at -1 and count down to avoid collisions with seq from the shard handler
  int seq = -1;

  late Encoding _encoding;

  ShardRunner(this.sendPort) {
    managerMessages.listen(handle);
  }

  /// Sends a message back to the manager.
  void execute(ShardMessage<ShardToManager> message) => sendPort.send(message);

  /// Handler for uncompressed messages received from Discord.
  ///
  /// Calls jsonDecode and sends the data back to the manager.
  void receive(/* List<int>|RawApiMap|String */ dynamic payload) {
    if (payload is List<int>) {
      payload = utf8.decode(zlib.decode(payload));
    }

    return execute(ShardMessage(
      ShardToManager.received,
      seq: seq--,
      data: payload is String ? jsonDecode(payload) : payload,
    ));
  }

  /// Handler for incoming messages from the manager.
  Future<void> handle(ShardMessage<ManagerToShard> message) async {
    switch (message.type) {
      case ManagerToShard.send:
        return send(message.data, message.seq);
      case ManagerToShard.connect:
        return connect(message.data['gatewayHost'] as String, message.data['useCompression'] as bool, message.seq, message.data['encoding'] as Encoding,
            message.data['usePayloadCompression'] as bool);
      case ManagerToShard.reconnect:
        return reconnect(message.data['gatewayHost'] as String, message.data['useCompression'] as bool, message.seq, message.data['encoding'] as Encoding,
            message.data['usePayloadCompression'] as bool);
      case ManagerToShard.disconnect:
        return disconnect(message.seq);
      case ManagerToShard.dispose:
        return dispose(message.seq);
    }
  }

  /// Initiate the connection on this shard.
  ///
  /// Sends [ShardToManager.connected] upon completion.
  Future<void> connect(String gatewayHost, bool useCompression, int seq, Encoding encoding, bool usePayloadCompression) async {
    _encoding = encoding;
    if (connected) {
      execute(ShardMessage(
        ShardToManager.error,
        seq: seq,
        data: {'message': 'Shard is already connected'},
      ));
      return;
    }

    if (connecting) {
      execute(ShardMessage(
        ShardToManager.error,
        seq: seq,
        data: {'message': 'Shard is already connecting'},
      ));
      return;
    }

    connecting = true;

    try {
      final gatewayUri = Constants.gatewayUri(gatewayHost, useCompression, encoding);

      connection = await WebSocket.connect(gatewayUri.toString());
      connection!.pingInterval = const Duration(seconds: 20);

      connection!.done.then((_) {
        if (reconnecting || disposing) {
          return;
        }

        execute(ShardMessage(
          ShardToManager.disconnected,
          seq: seq,
          data: {
            'closeCode': connection!.closeCode!,
            'closeReason': connection!.closeReason,
          },
        ));
      });

      if (useCompression) {
        final filter = RawZLibFilter.inflateFilter();

        final mappedConnection = connection!.cast<List<int>>().map((rawPayload) {
          filter.process(rawPayload, 0, rawPayload.length);

          final buffer = <int>[];
          for (List<int>? decoded = []; decoded != null; decoded = filter.processed()) {
            buffer.addAll(decoded);
          }

          return buffer;
        });

        Stream< /* RawApiMap|String */ dynamic> stream;

        if (encoding == Encoding.etf) {
          stream = mappedConnection.transform(eterl.unpacker<RawApiMap>());
        } else {
          stream = mappedConnection.transform(utf8.decoder);
        }

        connectionSubscription = stream.listen(receive);
      } else {
        if (usePayloadCompression) {
          connectionSubscription = connection!.listen(receive);
        } else {
          connectionSubscription =
              (encoding == Encoding.json ? connection!.cast<String>() : connection!.cast<List<int>>().transform(eterl.unpacker<RawApiMap>())).listen(receive);
        }
      }

      execute(ShardMessage(reconnecting ? ShardToManager.reconnected : ShardToManager.connected, seq: seq));
    } catch (err) {
      if (err is IOException || err is OSError) {
        execute(ShardMessage(ShardToManager.error, seq: seq, data: {'message': err.toString(), 'shouldReconnect': true}));
      } else {
        execute(ShardMessage(ShardToManager.error, seq: seq, data: {'message': 'Unhanded exception $err'}));
      }
    }

    connecting = false;
  }

  /// Reconnect to the server, closing the connection if necessary.
  Future<void> reconnect(String gatewayHost, bool useCompression, int seq, Encoding encoding, bool usePayloadCompression) async {
    if (reconnecting) {
      execute(ShardMessage(
        ShardToManager.error,
        seq: seq,
        data: {'message': 'Shard is already reconnecting'},
      ));
    }

    reconnecting = true;
    if (connected) {
      // Don't send a normal close code so that the bot doesn't appear offline during the reconnect.
      await disconnect(seq, 3001);
    }

    // Sends reconnected instead of connected so we don't have to send it here
    await connect(gatewayHost, useCompression, seq, encoding, usePayloadCompression);
    reconnecting = false;
  }

  /// Terminate the connection on this shard.
  ///
  /// Sends [ShardToManager.disconnected].
  Future<void> disconnect(int seq, [int closeCode = 1000]) async {
    if (!connected) {
      execute(ShardMessage(
        ShardToManager.error,
        seq: seq,
        data: {'message': 'Cannot disconnect shard if no connection is active'},
      ));
    }

    // Closing the connection will trigger the `connection.done` future we listened to when connecting, which will execute the [ShardToManager.disconnected]
    // message.
    await connection!.close(closeCode);

    connection = null;
    connectionSubscription = null;
  }

  /// Sends data on this shard.
  Future<void> send(dynamic data, int seq) async {
    if (!connected) {
      execute(ShardMessage(
        ShardToManager.error,
        seq: seq,
        data: {'message': 'Cannot send data when connection is closed'},
      ));
    }

    connection!.add(_encoding == Encoding.json ? jsonEncode(data) : eterl.pack(data));
  }

  /// Disposes of this shard.
  ///
  /// Sends [ShardToManager.disposed] upon completion.
  @override
  Future<void> dispose([int? seq]) async {
    disposing = true;
    seq ??= (this.seq--);

    if (connected) {
      await disconnect(seq);
    }

    receivePort.close();
    execute(ShardMessage(ShardToManager.disposed, seq: seq));
  }
}
