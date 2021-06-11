part of nyxx_lavalink;

/*
  The actual node runner
  Following nyxx design, the node communicates with the cluster using json
  First message will always be the [NodeBuilder] data

  Can receive:
  * CONNECT - Attempts to connect to lavalink server
  * RECONNECT - Reconnects to the server
  * DISCONNECT - Disconnects from the server
  * SEND - Sends a given json payload directly to the server through the web socket
  * UPDATE - Updates the current node data
  * SHUTDOWN - Shuts down the node and kills the isolate

  Can send:
  * DISPATCH - Dispatch the given event
  * DISCONNECTED - WebSocket disconnected
  * CONNECTED - WebSocket connected
  * ERROR - An error occurred
*/
Future<void> _handleNode(SendPort clusterPort) async {

  WebSocket? socket;
  StreamSubscription? socketStream;

  // First thing to do is ro return a send port to the cluster to communicate with the node
  final receivePort = ReceivePort();
  clusterPort.send(receivePort.sendPort);

  var node = NodeOptions._fromJson(await receivePort.first as Map<String, dynamic>);

  Future<void> processEvent(Map<String, dynamic> json) async {
    switch(json["type"]) {
      case "TrackStartEvent":
        clusterPort.send({"cmd": "DISPATCH", "event": "TrackStart", "data": json});
        break;

      case "TrackEndEvent":
        clusterPort.send({"cmd": "DISPATCH", "event": "TrackEnd", "data": json});
        break;

      case "WebSocketClosedEvent":
        clusterPort.send({"cmd": "DISPATCH", "event": "WebSocketClosed", "data": json});
        break;
    }
  }

  Future<void> process(Map<String, dynamic> json) async {
    switch(json["op"]) {
      case "stats":
        clusterPort.send({"cmd": "DISPATCH", "event": "Stats", "data": json});
        break;

      case "playerUpdate":
        clusterPort.send({"cmd": "DISPATCH", "event": "PlayerUpdate", "data": json});
        break;

      case "event":
        await processEvent(json);
        break;
    }
  }

  Future<void> connect() async {
    final address = node.ssl ? "wss://${node.port}:${node.port}" : "ws://${node.port}:${node.port}";

    await WebSocket.connect(address, headers: {
      "Authorization": node.password,
      "Num-Shards": node.shards,
      "User-Id": node.clientId.id
    }).then((ws) {
      socket = ws;

      socketStream = socket!.listen((data) {
        clusterPort.send({"cmd": "DISPATCH", "event": "Raw", "data": jsonDecode(data as String)});

        process(jsonDecode(data) as Map<String, dynamic>);
      }, onDone: () async {
        clusterPort.send({"cmd": "DISCONNECTED"});
      },
        cancelOnError: true,
        onError: (err) {
          clusterPort.send({"cmd": "ERROR", "code": socket!.closeCode, "reason": socket!.closeReason});
        }
      );
    });
  }

  Future<void> disconnect() async {

  }

  Future<void> reconnect() async {

  }

  await for (final msg in receivePort) {
    switch (msg["cmd"]) {
      case "CONNECT":
        await connect();
        break;

      case "RECONNECT":
        await reconnect();
        break;

      case "DISCONNECT":
        await disconnect();
        break;

      case "SEND":
        socket?.add(jsonEncode(msg["data"]));
        break;

      case "UPDATE":
        node = NodeOptions._fromJson(msg["data"] as Map<String, dynamic>);
        break;

      case "SHUTDOWN": {
        Isolate.current.kill();
      }
      break;

      default:
        break;
    }
  }
}