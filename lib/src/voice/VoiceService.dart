part of nyxx.voice;

// Logger instance for `Voice Service`
Logger _logger = Logger.detached("Voice Service");

/// Sends Op4 and connects to voice channel but without starting voice service
Future<void> sendFakeOp4(Nyxx client, VoiceChannel channel, {bool mute = false, bool deafen = false}) async {
  channel.guild.shard.send(
      "VOICE_STATE_UPDATE", _Opcode4(channel.guild, channel, mute, deafen)._build());
}

/// Inits voice service. [yamlConfigFile] is absolute path to lavalink config file.
/// Returns instance of VoiceService
VoiceService init(String clientId, Nyxx client, String yamlConfigFile) {
  if (_manager != null) throw Exception("Tried initialize VoiceService twice.");

  _manager = VoiceService._new(clientId, client, yamlConfigFile);
  _logger.info("Voice service intitailized!");
  return _manager;
}

/// Returns instance of VoiceService
VoiceService getVoiceService() {
  if (_manager == null)
    throw Exception(
        "Cannot get initialized VoiceService! Init voice service with VoiceService.init()");

  return _manager;
}

/// Gets [Player] instance for guild.
Future<Player> getPlayer(Guild guild) async {
  _logger.fine("Node for guild -${guild.id}- connected!");
  return await _manager.getPlayer(guild);
}

/// Destroys player and removes all connections
Future<void> destroyPlayer(Player player) async {
  _logger.fine("Node for guild -${player._guild.id}- disconnected!");
  _manager.removePlayer(player._guild.id.toString());
  player = null;
}

// Singleton instance of voiceService
VoiceService _manager;

/// [VoiceService] managers all voice connections.
/// There can be only one instance class.
class VoiceService {
  Uri _wsPath;
  Uri _restPath;
  Nyxx _client;
  WebSocket _webSocket;
  String _password;
  String _clientId;

  static Map<String, Player> _playersCache = Map();

  StreamController<Stats> _onStats;
  Stream<Stats> onStats;

  VoiceService._new(this._clientId, this._client, String yamlConfigFile) {
    var file = File(yamlConfigFile);
    var contents = file.readAsStringSync();
    var config = loadYaml(contents);

    _onStats = StreamController.broadcast();
    onStats = _onStats.stream;

    this._wsPath = Uri.parse(
        "ws://${config['lavalink']['server']['ws']['host']}:${config['lavalink']['server']['ws']['port']}");
    this._password = config['lavalink']['server']['password'] as String;
    this._restPath = Uri.parse(
        "http://${config['server']['address']}:${config['server']['port']}");

    _connect();
  }

  // Connects to main websocket. And starts dispatching messages.
  Future<void> _connect() async {
    try {
      WebSocket.connect(_wsPath.toString(), headers: {
        "Authorization": _password,
        "Num-Shards": _client.shards.length,
        "User-Id": _clientId
      }).then((wc) {
        this._webSocket = wc;
        _webSocket.listen((data) async {
          await _handleMsg(jsonDecode(data as String) as Map<String, dynamic>);
        });
      });
    } catch (e) {
      //print("FAILED TO CONNECT. TRYING AGAIN!");
      // new Timer(const Duration(seconds: 2), () async => await _connect);
    }
  }

  // Handles incoming message. Tries to parse and takes actions
  Future<void> _handleMsg(Map<String, dynamic> msg) async {
    var op = msg['op'] as String;

    switch (op) {
      case 'playerUpdate':
        var e = PlayerUpdateEvent._new(msg);
        if (_playersCache[e.guildId].isConnected)
          _playersCache[e.guildId]._onPlayerUpdate.add(e);
        break;
      case 'stats':
        _onStats.add(Stats._new(msg));
        break;
      case 'event':
        var player = _playersCache[msg['guildId']];
        TrackError evnt;
        switch (msg['type'] as String) {
          case 'TrackEndEvent':
            evnt = TrackEndEvent(msg);
            break;
          case 'TrackExceptionEvent':
            evnt = TrackExceptionEvent(msg);
            break;
          case 'TrackStuckEvent':
            evnt = TrackStuckEvent(msg);
            break;
        }
        player._onTrackError.add(evnt);
        break;
      default:
        print("!");
    }
  }

  /// Gets [Player] instance for guild.
  Future<Player> getPlayer(Guild guild) {
    return Future<Player>.delayed(const Duration(seconds: 2), () {
      if (_playersCache.containsKey(guild.id.toString()))
        return _playersCache[guild.id.toString()];
      else {
        var tmp = Player._new(guild, _client, _webSocket, _restPath, _password);
        _playersCache[guild.id.toString()] = tmp;
        return tmp;
      }
    });
  }

  /// Destroys player and removes all connections
  Future<void> removePlayer(String guild) async {
    await _playersCache[guild]._finish();
    _playersCache.remove(guild);
  }
}
