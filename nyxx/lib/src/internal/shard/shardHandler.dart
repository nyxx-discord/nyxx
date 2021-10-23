import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:nyxx/src/internal/Constants.dart';
import 'package:nyxx/src/typedefs.dart';

// Decodes zlib compresses string into string json
RawApiMap _decodeBytes(dynamic rawPayload, RawZLibFilter decoder) {
  if (rawPayload is String) {
    return jsonDecode(rawPayload) as RawApiMap;
  }

  decoder.process(rawPayload as List<int>, 0, rawPayload.length);

  final buffer = <int>[];
  for (List<int>? decoded = []; decoded != null; decoded = decoder.processed()) {
    buffer.addAll(decoded);
  }

  // that shouldn't really happen
  if (buffer.isEmpty) {
    return {};
  }

  final rawStr = utf8.decode(buffer);
  return jsonDecode(rawStr) as RawApiMap;
}

/*
Protocol used to communicate with shard isolate.
  First message delivered to shardHandler will be init message with gateway uri

 * DATA - sent along with data received from websocket
 * DISCONNECTED - sent when shard disconnects
 * ERROR - sent when error occurs

 * INIT - inits ws connection
 * CONNECT - sent when ws connection is established. additional data can contain if reconnected.
 * SEND - sent along with data to send via websocket
*/
Future<void> shardHandler(SendPort shardPort) async {
  /// Port init
  final receivePort = ReceivePort();
  final receiveStream = receivePort.asBroadcastStream();

  final sendPort = receivePort.sendPort;
  shardPort.send(sendPort);

  /// Initial data init
  final initData = await receiveStream.first;
  final gatewayUri = Constants.gatewayUri(initData["gatewayUrl"] as String, initData["compression"] as bool);

  WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  Future<void> terminate() async {
    await _socketSubscription?.cancel();
    await _socket?.close(1000);
    shardPort.send({ "cmd" : "TERMINATE_OK" });
  }

  if(!Platform.isWindows) {
    // ignore: unawaited_futures
    ProcessSignal.sigterm.watch().forEach((event) async {
      await terminate();
    });
  }

  // ignore: unawaited_futures
  ProcessSignal.sigint.watch().forEach((event) async {
    await terminate();
  });

  // Attempts to connect to ws
  Future<void> _connect() async {
    try {
      _socket = await WebSocket.connect(gatewayUri.toString());
      final zlibDecoder = RawZLibFilter.inflateFilter(); // Create zlib decoder specific to this connection. New connection should get new zlib context

      // ignore: unawaited_futures
      _socket!.done.then((value) {
        shardPort.send({ "cmd" : "DISCONNECTED", "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason });
      });

      _socket!.handleError((err) {
        shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason });
      });

      _socketSubscription = _socket!.listen((data) {
        shardPort.send({ "cmd" : "DATA", "jsonData" : _decodeBytes(data, zlibDecoder) });
      });

      shardPort.send({ "cmd" : "CONNECT_ACK" });
    } on WebSocketException catch (err) {
      shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason });
    } on Exception catch (err) {
      print(err);
    } on Error catch (err) {
      print(err);
    }
  }

  // Connects
  await _connect();

  await for(final message in receiveStream) {
    final cmd = message["cmd"];

    if(cmd == "SEND") {
      if(_socket?.closeCode == null) {
        _socket?.add(jsonEncode(message["data"]));
      }

      continue;
    }

    if(cmd == "CONNECT") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      await _connect();

      continue;
    }
  }
}
