part of nyxx_lavalink;


/// Cluster of lavalink nodes
class Cluster {
  /// A reference to the client
  final Nyxx client;

  /// The client id provided to lavalink;
  final Snowflake clientId;

  /// All available nodes
  final Map<int, Node> nodes = {};

  /// A map to keep the assigned node id for each player
  final Map<Snowflake, int> _nodeLocations = {};

  int _lastId = 0;

  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;

  final _logger = logging.Logger("Lavalink cluster");

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

    /// Set a tiny delay so we can ensure we don't repeat ids
    await Future.delayed(const Duration(milliseconds: 50));

    this._lastId += 1;

    await this._addNode(options, this._lastId);
  }

  Future<void> _addNode(NodeOptions nodeOptions, int nodeId) async {
    await Isolate.spawn(_handleNode, this._receivePort.sendPort);

    final isolateSendPort = await this._receiveStream.first as SendPort;

    nodeOptions.clientId = this.clientId;
    nodeOptions._nodeId = nodeId;

    isolateSendPort.send(nodeOptions._toJson());

    isolateSendPort.send({"cmd": "CONNECT"});

    final node = Node._fromOptions(nodeOptions, isolateSendPort);

    this.nodes[nodeId] = node;
  }

  Future<void> _handleNodeMessage(dynamic message) async {
    if (message is SendPort) return;
    final map = message as Map<String, dynamic>;

    this._logger.log(logging.Level.FINE, "Receved data from node ${map["nodeId"]}, data: $map");

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

  void _registerEvents() {
    this.client.onVoiceServerUpdate.listen((event) async {
      await Future.delayed(const Duration(milliseconds: 100));

      final node = this.nodes[this._nodeLocations[event.guild.id]];

      if(node == null) return;

      final player = node.players[event.guild.id];

      if(player == null) return;

      player._handleServerUpdate(event);
    });

    this.client.onVoiceStateUpdate.listen((event) async {
      if(!(event.raw["d"]["user_id"] == clientId.toString())) return;

      await Future.delayed(const Duration(milliseconds: 100));

      final node = this.nodes[this._nodeLocations[event.state.guild!.id]];

      if(node == null) return;

      final player = node.players[event.state.guild!.id];

      if(player == null) return;

      player._handleStateUpdate(event);
    });
  }

  /// Creates a new cluster ready to start adding connections
  Cluster(this.client, this.clientId) {
    this._registerEvents();

    this._eventDispatcher = _EventDispatcher(this);

    this._receiveStream = this._receivePort.asBroadcastStream();

    this._receiveStream.listen(_handleNodeMessage);
  }

  Node? getBestNode() {
    return null;
  }

  Node getOrCreatePlayerNode(Snowflake guildId) {
    Node node;

    if (this._nodeLocations.containsKey(guildId)) {
      node = this.nodes[_nodeLocations[guildId]!]!;
    } else {
      node = this.nodes[1]!;
      this._nodeLocations[guildId] = node.options._nodeId;
      node.players[guildId] = GuildPlayer._new(node, guildId);
    }

    return node;
  }
}