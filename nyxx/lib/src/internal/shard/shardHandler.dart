part of nyxx;

// Decodes zlib compresses string into string json
Map<String, dynamic> _decodeBytes(dynamic rawPayload, ZLibDecoder decoder) {
  if (rawPayload is String) {
    return jsonDecode(rawPayload) as Map<String, dynamic>;
  }

  // print("Size: ${(rawPayload as List<int>).length} bytes");

  final decoded = decoder.convert(rawPayload as List<int>);
  final rawStr = utf8.decode(decoded);
  return jsonDecode(rawStr) as Map<String, dynamic>;
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
Future<void> _shardHandler(SendPort shardPort) async {
  /// Port init
  final receivePort = ReceivePort();
  final receiveStream = receivePort.asBroadcastStream();

  final sendPort = receivePort.sendPort;
  shardPort.send(sendPort);

  /// Initial data init
  final initData = await receiveStream.first;
  final gatewayUri = Constants.gatewayUri(initData["gatewayUrl"] as String);

  transport.WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  transport_vm.configureWTransportForVM();

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
    await transport.WebSocket.connect(gatewayUri).then((ws) {
      final zlibDecoder = ZLibDecoder(); // Create zlib decoder specific to this connection. New connection should get new zlib context

      _socket = ws;
      _socketSubscription = _socket!.listen((data) {
        shardPort.send({ "cmd" : "DATA", "jsonData" : _decodeBytes(data, zlibDecoder) });
      }, onDone: () async {
        shardPort.send({ "cmd" : "DISCONNECTED", "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason });
      }, cancelOnError: true, onError: (err) => shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason }));

      shardPort.send({ "cmd" : "CONNECT_ACK" });
    }, onError: (err, __) => shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason }));
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
