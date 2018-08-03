part of nyxx.voice;

class VoiceManager {
  Uri _wsPath;
  Uri _restPath;
  String _password;
  String _clientId;

  Client _client;
  w_transport.WebSocket _webSocket;

  Guild _guild;

  VoiceState currentState;
  dynamic rawEvent;

  bool isPlaying = false;
  VoiceChannel currentChannel;

  VoiceManager(this._clientId, this._client, this._guild, String yamlConfigFile) {
    var file = new File(yamlConfigFile);
    var contents = file.readAsStringSync();
    var config = loadYaml(contents);

    this._wsPath = Uri.parse("ws://${config['lavalink']['server']['ws']['host']}:${config['lavalink']['server']['ws']['port']}");
    this._password = config['lavalink']['server']['password'] as String;
    this._restPath = Uri.parse("http://${config['server']['address']}:${config['server']['port']}");

    _connect();
  }

  Future _connect() {
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
  }

  Future<Null> connect(VoiceChannel channel) async {
    currentChannel = channel;
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, channel, false, false)._build());

    var stateUp = await _client.onVoiceStateUpdate.first;
    var servUp = await _client.onVoiceServerUpdate.first;
    rawEvent = servUp.raw;
    currentState = stateUp.state;

    _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), currentState.sessionId, rawEvent).build()));

    _client.onVoiceServerUpdate.listen((e) {
      rawEvent = e.raw;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), currentState.sessionId, rawEvent).build()));
    });

    _client.onVoiceStateUpdate.listen((e) {
      currentState = e.state;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), currentState.sessionId, rawEvent).build()));
    });
  }

  Future<Null> changeChannel(VoiceChannel channel, {bool muted: false, bool deafen: false}) {
    currentChannel = channel;
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, channel, muted, deafen)._build());
  }

  Future<Null> play(String song) async {
    var req = w_transport.JsonRequest()
      ..uri = _restPath
      ..path = "/loadtracks"
      ..headers = { "Authorization": "password" }
      ..queryParameters = { "identifier" : song };

    var res = await req.send("GET");

    if(res.status != 200)
      throw new Exception("Cannot comunicate with lavalink wia http");

    var r = res.body.asJson() as Map<String, dynamic>;
    var track = new TrackResponse._new(r);

    _webSocket.add(jsonEncode(new OpPlay(_guild, track.entity as Track).build()));
    isPlaying = false;
  }

  Future<Null> disconnect() async {
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, null, false, false)._build());
    _webSocket.add(jsonEncode(new OpPause(_guild).build()));
  }

  Future<Null> stop() async {
    //_guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, null, false, false)._build());
    _webSocket.add(jsonEncode(new OpPause(_guild).build()));
  }

  Future<Null> handleMsg(Map<String, dynamic> msg) async {
    var op = msg['op'] as String;

    switch(op) {
      case 'playerUpdate':
        print(msg);
        break;
      case 'stats':
        break;
      case 'event':
        break;
      default:
        print("Fault!");
    }
  }
}