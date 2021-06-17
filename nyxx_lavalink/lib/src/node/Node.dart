part of nyxx_lavalink;

/// Represents an active and running lavalink node
class Node {
  /// Node options, such as host, port, etc..
  NodeOptions options;

  /// A map with guild ids as keys and players as values
  Map<Snowflake, GuildPlayer> players = {};

  /// Last stats received by this node
  StatsEvent? stats;

  /// Http client used with this node
  final Client _httpClient = Client();

  final SendPort _nodeSendPort;
  late String _httpUri;
  late Map<String, String> _defaultHeaders;
  final _Cluster _cluster;
  /// A regular expression to avoid searching when a link is provided
  final RegExp _urlRegex = RegExp(r"https?://(?:www\.)?.+");

  /// Build a new Node
  Node._fromOptions(this._cluster, this.options, this._nodeSendPort) {
    this._httpUri = options.ssl
        ? "https://${options.host}:${options.port}"
        : "http://${options.host}:${options.port}";

    this._defaultHeaders = {
      "Authorization": options.password,
      "Num-Shards": options.shards.toString(),
      "User-Id": options.clientId.toString()
    };
  }

  void _sendPayload(String op, Snowflake guildId, [Map<String, dynamic>? data]) async {
    if (data == null) {
      _nodeSendPort.send({"cmd": "SEND", "data": {
        "op": op,
        "guildId": guildId.toString(),
      }});
    } else {
      _nodeSendPort.send({"cmd": "SEND", "data": {
        "op": op,
        "guildId": guildId.toString(),
        ...data
      }});
    }
  }

  void _playNext(Snowflake guildId) async {
    final player = this.players[guildId];

    if (player == null) {
      return;
    }

    final track = player.queue[0];

    player.nowPlaying = track;

    if (track.endTime == null) {
      this._sendPayload("play", guildId, {
        "track": track.track.track,
        "noReplace": false,
        "startTime": track.startTime.inMilliseconds,
      });
    } else {
      this._sendPayload("play", guildId, {
        "track": track.track.track,
        "noReplace": false,
        "startTime": track.startTime.inMilliseconds,
        "endTime": track.endTime!.inMilliseconds
      });
    }
  }

  void _handleTrackEnd(TrackEnd event) {
    if(!(event.reason == "FINISHED")) {
      return;
    }

    final player = this.players[event.guildId];

    if (player == null) {
      return;
    }

    player.queue.removeAt(0);
    player.nowPlaying = null;

    if (player.queue.isEmpty) {
      return;
    }


    _playNext(event.guildId);
  }

  /// Destroys a player
  void destroy(Snowflake guildId) {
    _sendPayload("destroy", guildId);

    // delete the actual player
    this.players.remove(guildId);

    // delete the relationship between this node and the player so
    // if this guild creates a new player, it can be assigned to other node
    this._cluster._nodeLocations.remove(guildId);
  }

  /// Stops a player
  void stop(Snowflake guildId) {
    final player = this.players[guildId];

    if (player == null) {
      return;
    }

    player.queue.clear();
    player.nowPlaying = null;

    _sendPayload("stop", guildId);
  }

  /// Skips a track, starting the next one if available or stopping the player if not
  void skip(Snowflake guildId) {
    final player = this.players[guildId];

    if (player == null) {
      return;
    }

    if (player.queue.isEmpty) {
      return;
    } else if (player.queue.length == 1) {
      stop(guildId);
      return;
    } else {
      player.queue.removeAt(0);
      this._playNext(guildId);
    }
  }

  /// Set the pause state of a player
  ///
  /// this method is internally used by [resume] and [pause]
  void setPause(Snowflake guildId, bool pauseState) {
    _sendPayload("pause", guildId, {"pause": pauseState});
  }

  /// Seeks for a given time at the currently playing track
  void seek(Snowflake guildId, Duration time) {
    _sendPayload("seek", guildId, {
      "position": time.inMilliseconds
    });
  }

  /// Sets the volume for a guild player
  void volume(Snowflake guildId, int volume) {
    final trimmed = max(min(volume, 1000), 0);

    _sendPayload("volume", guildId, {
      "volume": trimmed
    });
  }

  /// Pauses a guild player
  void pause(Snowflake guildId) {
    setPause(guildId, true);
  }

  /// Resumes the track playback of a guild player
  void resume(Snowflake guildId) {
    setPause(guildId, false);
  }

  /// Searches a given query over the lavalink api and returns the results
  Future<Tracks> searchTracks(String query) async {
    final response = await _httpClient.get(Uri.parse(
      "${this._httpUri}/loadtracks?identifier=$query"),
      headers: this._defaultHeaders
    );

    if (!(response.statusCode == 200)) {
      throw HttpException._new(response.statusCode);
    }

    return Tracks._fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Searches a provided query on youtube, if the query is a link
  /// it's searched directly by the link
  Future<Tracks> autoSearch(String query) async {

    if (this._urlRegex.hasMatch(query)) {
      return searchTracks(query);
    }

    return searchTracks("ytsearch:$query");
  }

  /// Get the [PlayParameters] object for a specific track
  PlayParameters play(Snowflake guildId, Track track, {
    bool replace = false,
    Duration startTime = const Duration(),
    Duration? endTime,
    Snowflake? requester,
    Snowflake? channelId
  }) => PlayParameters(
    this,
    track,
    guildId,
    replace,
    startTime,
    endTime,
    requester,
    channelId
  );

  /// Shuts down the node
  void shutdown() {
    this._nodeSendPort.send({"cmd": "SHUTDOWN"});
  }

  /// Create a new player for a specific guild
  GuildPlayer createPlayer(Snowflake guildId) {
    final player = GuildPlayer._new(this, guildId);

    this.players[guildId] = player;
    _cluster._nodeLocations[guildId] = this.options.nodeId;

    return player;
  }

  /// Updates the [NodeOptions] property of the node, also reconnects the
  /// websocket to the new options
  void updateOptions(NodeOptions newOptions) {
    // Set the node id and client id before sending it to the isolate
    newOptions.clientId = this.options.clientId;
    newOptions.nodeId = this.options.nodeId;

    _nodeSendPort.send({"cmd": "UPDATE", "data": newOptions._toJson()});

    this.options = newOptions;
  }

  /// Tells the node to disconnect from lavalink server
  void disconnect() {
    _nodeSendPort.send({"cmd": "DISCONNECT"});
  }

  /// Tells the node to reconnect to lavalink server
  void reconnect() {
    _nodeSendPort.send({"cmd": "RECONNECT"});
  }

  @override
  String toString() =>
      "Node ${this.options.nodeId}";
}
