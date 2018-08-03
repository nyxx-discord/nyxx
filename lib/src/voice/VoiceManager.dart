part of nyxx.voice;

VoiceManager _manager = null;

class VoiceManager {
  Uri _wsPath;
  Uri _restPath;
  String _password;
  String _clientId;
  Client _client;
  w_transport.WebSocket _webSocket;

  static Map<String, Player> _playersCache = new Map();

  static VoiceManager getManager({String clientId, Client client, String yamlConfigFile}) {
    if(_manager == null) {
      _manager = new VoiceManager._new(clientId, client, yamlConfigFile);
      return _manager;
    }

    return _manager;
  }

  VoiceManager._new(this._clientId, this._client, String yamlConfigFile) {
    var file = new File(yamlConfigFile);
    var contents = file.readAsStringSync();
    var config = loadYaml(contents);

    this._wsPath = Uri.parse("ws://${config['lavalink']['server']['ws']['host']}:${config['lavalink']['server']['ws']['port']}");
    this._password = config['lavalink']['server']['password'] as String;
    this._restPath = Uri.parse("http://${config['server']['address']}:${config['server']['port']}");

    _connect();
  }

  Future<Null> _connect() {
    try {
      w_transport.WebSocket.connect(_wsPath, headers: {
        "Authorization": _password,
        "Num-Shards": _client.shards.length,
        "User-Id": _clientId
      }).then((wc) {
        this._webSocket = wc;
        _webSocket.listen((data) async {
          await handleMsg(jsonDecode(data as String) as Map<String, dynamic>);
        }).onError((err) {
          print("Das ist eine katastrofe");
        });
      });
    } on w_transport.WebSocketException {
      throw new Exception("Failed connect to websocket");
    }

    return null;
  }

  Future<Null> handleMsg(Map<String, dynamic> msg) async {
    var op = msg['op'] as String;

    switch(op) {
      case 'playerUpdate':
        var e = new PlayerUpdateEvent._new(msg);
        _playersCache[e.guildId].isConnected? _playersCache[e.guildId]._onPlayerUpdate.add(e) : {};
        break;
      case 'stats':
        break;
      case 'event':
        break;
      default:
        print("Fault!");
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
}