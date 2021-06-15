part of nyxx_lavalink;

/// Represents an active and running lavalink node
class Node {
  /// Node options, such as host, port, etc..
  NodeOptions options;

  /// A map with guild ids as keys and players as values
  Map<Snowflake, GuildPlayer> players = {};

  /// Http client used with this node
  final http.Client _httpClient = http.Client();

  final SendPort _nodeSendPort;
  late String _httpUri;
  late Map<String, String> _defaultHeaders;
  final _Cluster _cluster;
  /// A regular expression to avoid searching when a link is provided
  final RegExp _urlRegex = RegExp(r"https?://(?:www\.)?.+");

  /// Build a new Node
  Node._fromOptions(this._cluster, this.options, this._nodeSendPort) {
    this._httpUri =
        options.ssl ?
        "https://${options.host}:${options.port}"
            : "http://${options.host}:${options.port}";

    this._defaultHeaders = {
      "Authorization": options.password,
      "Num-Shards": options.shards.toString(),
      "User-Id": options.clientId.toString()
    };
  }

  Future<void> _sendPayload(String op, Snowflake guildId, [Map<String, dynamic>? data]) async {

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

  Future<void> _playNext(Snowflake guildId) async {
    final player = this.players[guildId];

    if (player == null) return;

    final track = player.queue[0];

    player.nowPlaying = track;

    if(track.endTime == null) {
      await this._sendPayload("play", guildId, {
        "track": track.track.track,
        "noReplace": false,
        "startTime": track.startTime,
      });
    } else {
      await this._sendPayload("play", guildId, {
        "track": track.track.track,
        "noReplace": false,
        "startTime": track.startTime,
        "endTime": track.endTime
      });
    }
  }

  Future<void> _handleTrackEnd(TrackEnd event) async {
    if(!(event.reason == "FINISHED")) return;

    final player = this.players[event.guildId];

    if (player == null) return;

    player.queue.removeAt(0);
    player.nowPlaying = null;

    if (player.queue.isEmpty) return;


    await _playNext(event.guildId);
  }

  /// Destroys a player
  Future<void> destroy(Snowflake guildId) async {
    await _sendPayload("destroy", guildId);

    this.players.remove(guildId);
  }

  /// Stops a player
  Future<void> stop(Snowflake guildId) async {
    final player = this.players[guildId];

    if (player == null) return;

    player.queue.clear();
    player.nowPlaying = null;

    await _sendPayload("stop", guildId);
  }

  Future<void> skip(Snowflake guildId) async {
    final player = this.players[guildId];

    if (player == null) return;

    if (player.queue.isEmpty) {
      return;
    } else if (player.queue.length == 1) {
      await stop(guildId);
      return;
    } else {
      player.queue.removeAt(0);
      await this._playNext(guildId);
    }
  }

  Future<void> setPause(Snowflake guildId, bool pause) async {
    await _sendPayload("pause", guildId, {"pause": pause});
  }

  Future<void> seek(Snowflake guildId, Duration time) async {
    await _sendPayload("seek", guildId, {
      "position": time.inMilliseconds
    });
  }

  Future<void> volume(Snowflake guildId, int volume) async {
    final trimmed = max(min(volume, 1000), 0);

    await _sendPayload("volume", guildId, {
      "volume": trimmed
    });
  }

  Future<void> pause(Snowflake guildId) async {
    await setPause(guildId, true);
  }

  Future<void> resume(Snowflake guildId) async {
    await setPause(guildId, true);
  }
  
  Future<Tracks> searchTracks(String query) async {
    final response = await _httpClient.get(Uri.parse(
      "${this._httpUri}/loadtracks?identifier=$query"),
      headers: this._defaultHeaders
    );

    if(!(response.statusCode == 200)) throw HttpException._new(response.statusCode);

    return Tracks._fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Searches a provided query on youtube, if the query is a link
  /// it's searched directly by the link
  Future<Tracks> autoSearch(String query) async {

    if(this._urlRegex.hasMatch(query)) {
      return searchTracks(query);
    }

    return searchTracks("ytsearch:$query");
  }

  /// Get the [PlayParameters] object for a specific track
  PlayParameters play(Snowflake guildId, Track track, {
    bool replace = false,
    int startTime = 0,
    int? endTime,
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

  @override
  String toString() =>
      "Node ${this.options.nodeId}";
}