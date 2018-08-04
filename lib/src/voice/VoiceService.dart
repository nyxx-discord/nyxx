part of nyxx.voice;

VoiceService init(String clientId, Client client, String yamlConfigFile) {
  if(_manager != null)
    throw new Exception("Tried initialize VoiceService twice.");

  _manager = new VoiceService._new(clientId, client, yamlConfigFile);
  return _manager;
}

VoiceService getVoiceService() {
  if(_manager == null)
    throw new Exception("Cannot get initialized VoiceService! Init voice service with VoiceService.init()");

  return _manager;
}

Future<Player> getPlayer(Guild guild) async {
  return await _manager.getPlayer(guild);
}

Future<Null> destroyPlayer(Player player) async {
  _manager._removePlayer(player._guild.id.toString());
  player = null;
}

VoiceService _manager = null;

class VoiceService {
  Uri _wsPath;
  Uri _restPath;
  Client _client;
  w_transport.WebSocket _webSocket;
  String _password;
  String _clientId;

  static Map<String, Player> _playersCache = new Map();

  StreamController<Stats> _onStats;
  Stream<Stats> onStats;

  VoiceService._new(this._clientId, this._client, String yamlConfigFile) {
    var file = new File(yamlConfigFile);
    var contents = file.readAsStringSync();
    var config = loadYaml(contents);

    _onStats = new StreamController.broadcast();
    onStats = _onStats.stream;

    this._wsPath = Uri.parse("ws://${config['lavalink']['server']['ws']['host']}:${config['lavalink']['server']['ws']['port']}");
    this._password = config['lavalink']['server']['password'] as String;
    this._restPath = Uri.parse("http://${config['server']['address']}:${config['server']['port']}");

    _connect();
  }

  Future<Null> _connect() async {
    try {
      w_transport.WebSocket.connect(_wsPath, headers: {
        "Authorization": _password,
        "Num-Shards": _client.shards.length,
        "User-Id": _clientId
      }).then((wc) {
        this._webSocket = wc;
        _webSocket.listen((data) async {
          print("RAW WEBSOCKET: $data");
          await _handleMsg(jsonDecode(data as String) as Map<String, dynamic>);
        });
      });
    } catch (e) {
      //print("FAILED TO CONNECT. TRYING AGAIN!");
     // new Timer(const Duration(seconds: 2), () async => await _connect);
    }

    return null;
  }

  Future<Null> _handleMsg(Map<String, dynamic> msg) async {
    var op = msg['op'] as String;

    switch(op) {
      case 'playerUpdate':
        var e = new PlayerUpdateEvent._new(msg);
        _playersCache[e.guildId].isConnected ? _playersCache[e.guildId]._onPlayerUpdate.add(e) : {};
        break;
      case 'stats':
        _onStats.add(new Stats._new(msg));
        break;
      case 'event':
        break;
      default:
        print("!");
    }
  }

  Future<Player> getPlayer(Guild guild) {
    return new Future<Player>.delayed(const Duration(seconds: 2), () {
      if(_playersCache.containsKey(guild.id.toString()))
        return _playersCache[guild.id.toString()];
      else {
        var tmp = new Player._new(guild, _client, _webSocket, _restPath);
        _playersCache[guild.id.toString()] = tmp;
        return tmp;
      }
    });
  }

  Future<Null> _removePlayer(String guild) async {
   await _playersCache[guild].finish();
   _playersCache.remove(guild);
  }
}