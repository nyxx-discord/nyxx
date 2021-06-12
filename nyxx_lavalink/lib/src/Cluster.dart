part of nyxx_lavalink;


/// Cluster of lavalink nodes
class Cluster {
  /// A reference to the client
  final Nyxx client;

  /// The client id provided to lavalink;
  final Snowflake clientId;

  /// All available nodes
  final Map<int, Node> nodes = {};

  int _lastId = 0;

  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;

  final _logger = logging.Logger("Lavalink cluster");
  final Lock _lock = Lock();

  /// Emitted when stats are sent from lavalink
  late final Stream<Stats> onStatsReceived;
  /// Emitted when a player gets updated
  late final Stream<PlayerUpdate> onPlayerUpdate;
  /// Emitted when a track starts playing
  late final Stream<TrackStart> onTrackStart;
  /// Emitted when a track ends playing
  late final Stream<TrackEnd> onTrackEnd;
  /// Emitted when a web socket is closed
  late final Stream<WebSocketClosed> onWebSocketClosed;
  /// Emitted everytime an event is received
  late final Stream<Map<String, dynamic>> onRawEvent;

  late final _EventDispatcher _eventDispatcher;

  /// Add and initialize a node
  Future<void> addNode(NodeOptions options) async {
    final id = await this._lock.synchronized(() {
      final id = this._lastId + 1;

      this._lastId = id;

      return id;
    });

    this._addNode(options, id);
  }

  Future<void> _addNode(NodeOptions nodeOptions, int nodeId) async {
    final isolate = await Isolate.spawn(_handleNode, this._receivePort.sendPort);

    final isolateSendPort = await this._receiveStream.first as SendPort;

    nodeOptions.clientId = this.clientId;
    nodeOptions._nodeId = nodeId;

    isolateSendPort.send(nodeOptions._toJson());

    isolateSendPort.send({"cmd": "CONNECT"});

    final node = Node._fromOptions(nodeOptions, isolateSendPort, isolate);

    this.nodes[nodeId] = node;
  }

  Future<void> _handleNodeMessage(dynamic message) async {
    if (message is SendPort) return;
    final map = message as Map<String, dynamic>;

    this._logger.log(logging.Level.INFO, "Receved data from node id ${map["nodeId"]}, data: $map");

    switch(map["cmd"]) {
      case "DISPATCH":
        this._eventDispatcher.dispatchEvent(map);
        break;

      case "LOG": {
        logging.Level? level;

        switch (map["level"]) {
          case "INFO":
            level = logging.Level.INFO;
            break;

          case "WARNING":
            level = logging.Level.WARNING;
            break;
        }

        _logger.log(level!, map["message"]);
      }
      break;

      case "EXITED": {
        final nodeId = map["nodeId"]!;
        this.nodes.remove(nodeId as int);
      }
      break;
    }
  }

  /// Creates a new cluster ready to start adding connections
  Cluster(this.client, this.clientId) {
    this._eventDispatcher = _EventDispatcher(this);

    this._receiveStream = this._receivePort.asBroadcastStream();

    this._receiveStream.listen(_handleNodeMessage);
  }
}