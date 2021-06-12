part of nyxx_lavalink;

/// Represents an active and running lavalink node
class Node {
  /// Node options, such as host, port, etc..
  NodeOptions options;

  /// A map with guild ids as keys and players as values
  Map<Snowflake, GuildPlayer> players = {};

  /// Http client used with this node
  final http.Client _httpClient = http.Client();

  late SendPort _nodeSendPort;
  late String _httpUri;
  late Map<String, String> defaultHeaders;

  Isolate _nodeIsolate;

  /// Build a new Node
  Node._fromOptions(this.options, this._nodeSendPort, this._nodeIsolate) {
    this._httpUri =
        options.ssl ?
        "https://${options.host}:${options.port}"
            : "http://${options.host}:${options.port}";

    this.defaultHeaders = {
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

    if (player.queue.isEmpty) {
      await stop(guildId);
      return;
    }

    final track = player.queue[0];

    player.nowPlaying = track;

    await this._sendPayload("play", guildId, {
      "track": track.track.track,
      "noReplace": false,
      "startTime": track.startTime,
      "endTime": track.endTime
    });
  }

  /// Destroys a player
  Future<void> destroy(Snowflake guildId) async {
    await _sendPayload("destroy", guildId);
  }

  /// Stops a player
  Future<void> stop(Snowflake guildId) async {
    await _sendPayload("stop", guildId);
  }

  Future<void> skip(Snowflake guildId) async {
    // TODO: implement skip logic
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
      "${this._httpUri}?identifier=$query"),
      headers: this.defaultHeaders
    );

    if(!(response.statusCode == 200)) throw HttpException(response.statusCode);

    return Tracks._fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Tracks> youtubeSearch(String query) async => searchTracks("ytsearch:$query");


}