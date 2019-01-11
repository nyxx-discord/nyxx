part of nyxx.lavalink;

// Logger instance for `Voice Service`
Logger _logger = Logger.detached("Voice Service");

/// Sends Op4 and connects to voice channel but without starting voice service
Future<void> sendFakeOp4(VoiceChannel channel,
    {bool mute = false, bool deafen = false, Guild guild}) async {
  if (guild != null) {
    guild.client.shard.send(
        "VOICE_STATE_UPDATE", _Opcode4(guild, channel, mute, deafen)._build());
  } else {
    channel.guild.client.shard.send("VOICE_STATE_UPDATE",
        _Opcode4(channel.guild, channel, mute, deafen)._build());
  }
}

/// Creates voice service and connects to lavalink. [ws] is websocket connection String, [rest] is rest lavalink connection string. [password] to lavalink instance.
/// Returns instance of VoiceService
VoiceService init(String ws, String rest, String password, Nyxx client) {
  if (_manager != null) throw Exception("Tried initialize VoiceService twice.");

  _manager = VoiceService._new(ws, rest, password, client);
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
  transport.WebSocket _webSocket;
  String _password;

  static Map<Snowflake, Player> _playersCache = Map();

  StreamController<Stats> _onStats;
  Stream<Stats> onStats;

  Nyxx client;

  VoiceService._new(String ws, String rest, this._password, this.client) {
    _onStats = StreamController.broadcast();
    onStats = _onStats.stream;

    this._wsPath = Uri.parse("ws://$ws");
    this._restPath = Uri.parse("http://$rest");

    _connect();
  }

  // Connects to main websocket. And starts dispatching messages.
  Future<void> _connect() async {
    try {
      transport.WebSocket.connect(_wsPath, headers: {
        "Authorization": _password,
        "Num-Shards": client.shards,
        "User-Id": client.app.id.toString()
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
        if (_playersCache[e.guildId] != null &&
            _playersCache[e.guildId].isConnected)
          _playersCache[e.guildId]._onPlayerUpdate.add(e);
        break;
      case 'stats':
        _onStats.add(Stats._new(msg));
        break;
      case 'event':
        var player = _playersCache[msg['guildId']];

        if (player != null) {
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
        }
        break;
      default:
        print("!");
    }
  }

  /// Gets [Player] instance for guild.
  Future<Player> getPlayer(Guild guild) {
    return Future<Player>.delayed(const Duration(seconds: 2), () {
      if (_playersCache.containsKey(guild.id))
        return _playersCache[guild.id];
      else {
        var tmp = Player._new(guild);
        _playersCache[guild.id] = tmp;
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
