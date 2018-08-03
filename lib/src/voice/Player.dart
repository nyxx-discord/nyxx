part of nyxx.voice;

class Player {
  bool isConnected = false;
  bool isPlaying = false;
  VoiceChannel currentChannel;

  Guild _guild;
  Client _client;
  Uri _restPath;

  var sub1, sub2;

  dynamic _rawEvent;
  VoiceState _currentState;

  w_transport.WebSocket _webSocket;

  StreamController<PlayerUpdateEvent> _onPlayerUpdate;

  Stream<PlayerUpdateEvent> onPlayerUpdate;

  Player._new(this._guild, this._client, this._webSocket, this._restPath);

  Future<Null> connect(VoiceChannel channel) async {
    isConnected = true;
    currentChannel = channel;

    _onPlayerUpdate = new StreamController.broadcast();
    onPlayerUpdate = _onPlayerUpdate.stream;

    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, channel, false, false)._build());

    var stateUp = await _client.onVoiceStateUpdate.first;
    var servUp = await _client.onVoiceServerUpdate.first;
    _rawEvent = servUp.raw;
    _currentState = stateUp.state;

    _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));

    sub1 = _client.onVoiceServerUpdate.listen((e) {
      _rawEvent = e.raw;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
    });

    sub2 = _client.onVoiceStateUpdate.listen((e) {
      _currentState = e.state;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
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
      throw new Exception("Cannot comunicate with lavalink via http");

    var r = res.body.asJson() as Map<String, dynamic>;
    var track = new TrackResponse._new(r);

    _webSocket.add(jsonEncode(new OpPlay(_guild, track.entity as Track).build()));
    isPlaying = true;
  }

  Future<Null> disconnect() async {
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, null, false, false)._build());
    await stop();
    isPlaying = false;
    isConnected = false;
    sub1.cancel();
    sub2.cancel();
  }

  Future<Null> pause() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new OpPause(_guild).build()));
  }

  Future<Null> stop() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new OpStop(_guild).build()));
  }
}