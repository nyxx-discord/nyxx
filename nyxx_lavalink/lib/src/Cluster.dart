part of nyxx_lavalink;

class _Cluster {
  /// A reference to the client
  final Nyxx _client;

  /// The client id provided to lavalink;
  final Snowflake _clientId;

  /// All available nodes
  final Map<int, Node> _nodes = {};

  /// Nodes that are currently connecting to server, when a node gets connected
  /// it will be moved to [_nodes], and when reconnecting will be moved here again
  final Map<int, Node> _connectingNodes = {};

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

  Future<void> _addNode(NodeOptions nodeOptions, int nodeId) async {
    await Isolate.spawn(_handleNode, this._receivePort.sendPort);

    final isolateSendPort = await this._receiveStream.first as SendPort;

    nodeOptions.clientId = this._clientId;
    nodeOptions._nodeId = nodeId;

    isolateSendPort.send(nodeOptions._toJson());

    final node = Node._fromOptions(this, nodeOptions, isolateSendPort);

    this._connectingNodes[nodeId] = node;
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
        this._nodes.remove(nodeId as int);
      }
      break;

      case "CONNECTED": {
        final node = this._connectingNodes.remove(map["nodeId"] as int);

        if(node != null) {
          this._nodes[node.options._nodeId] = node;

          _logger.log(logging.Level.INFO, "[Node ${map["nodeId"]}] Connected to lavalink");
        }
      }
      break;

      case "DISCONNECTED": {
        final node = this._nodes.remove(map["nodeId"] as int);

        if(node != null) {
          this._connectingNodes[node.options._nodeId] = node;

          _logger.log(logging.Level.INFO, "[Node ${map["nodeId"]}] Disconnected from lavalink, trying to reconnect");
        }
      }
      break;
    }
  }

  void _registerEvents() {
    this._client.onVoiceServerUpdate.listen((event) async {
      await Future.delayed(const Duration(milliseconds: 100));

      final node = this._nodes[this._nodeLocations[event.guild.id]];

      if(node == null) return;

      final player = node.players[event.guild.id];

      if(player == null) return;

      player._handleServerUpdate(event);
    });

    this._client.onVoiceStateUpdate.listen((event) async {
      if(!(event.raw["d"]["user_id"] == _clientId.toString())) return;

      await Future.delayed(const Duration(milliseconds: 100));

      final node = this._nodes[this._nodeLocations[event.state.guild!.id]];

      if(node == null) return;

      final player = node.players[event.state.guild!.id];

      if(player == null) return;

      player._handleStateUpdate(event);
    });
  }

  /// Creates a new cluster ready to start adding connections
  _Cluster(this._client, this._clientId) {
    this._registerEvents();

    this._eventDispatcher = _EventDispatcher(this);

    this._receiveStream = this._receivePort.asBroadcastStream();

    this._receiveStream.listen(_handleNodeMessage);
  }
}

/// Cluster of lavalink nodes
class Cluster extends _Cluster {
  /// Creates a new lavalink cluster
  Cluster(Nyxx client, Snowflake clientId): super(client, clientId);

  /// Return the number of operating nodes
  int get nodes => this._nodes.length;

  /// Get the best available node, it is recommended to use [getOrCreatePlayerNode] instead
  Node getBestNode() {
    if(this._nodes.isEmpty) throw ClusterException._new("No available nodes");
    if(this._nodes.length == 1) {

      for(final k in this._nodes.keys) {
        // return first node if only one is connected
        return this._nodes[k]!;
      }
    }

    /// As dart doesn't have tuples this will contain the node with few players
    /// Order:
    ///   Index 0 - Node id
    ///   Index 1 - The number of players the node has
    final minNode = <int>[];

    this._nodes.forEach((id, node) {
      if(minNode.isEmpty) {
        minNode.add(id);
        minNode.add(node.players.length);
      } else {
        if (node.players.length < minNode[1]) {
          minNode[0] = id;
          minNode[1] = node.players.length;
        }
      }
    });

    return this._nodes[minNode[0]]!;
  }

  /// Attempts to get the node containing a player for a specific guild id
  ///
  /// if the player doesn't exist, then the best node is retrieved and the player created
  Node getOrCreatePlayerNode(Snowflake guildId) {
    final nodePreview = this._nodeLocations.containsKey(guildId) ?
        this._nodes[_nodeLocations[guildId]] : this.getBestNode();

    Node node;

    if(nodePreview == null) {
      node = this.getBestNode();
    } else {
      node = nodePreview;
    }

    if(!node.players.containsKey(guildId)) {
      node.createPlayer(guildId);
    }

    return node;
  }

  /// Add and initialize a node
  Future<void> addNode(NodeOptions options) async {

    /// Set a tiny delay so we can ensure we don't repeat ids
    await Future.delayed(const Duration(milliseconds: 50));

    this._lastId += 1;

    await this._addNode(options, this._lastId);
  }
}