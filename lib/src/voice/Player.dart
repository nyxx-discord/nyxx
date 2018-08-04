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

    _currentState = (await _client.onVoiceStateUpdate.first).state;
    _rawEvent =  (await _client.onVoiceServerUpdate.first).raw;

    var s = jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build());
    print(s);
    _webSocket.add(s);

    sub1 = _client.onVoiceServerUpdate.where((e) => e.guild.id.toString() == _guild.id.toString()).listen((e) {
      _rawEvent = e.raw;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
    });

    sub2 = _client.onVoiceStateUpdate.where((e) {
      if(e.state.channel != null)
        if(e.state.channel.id.toString() != currentChannel.id.toString())
          return false;

      return e.state.user.id.toString() == _client.user.id.toString();
    }).listen((e) {
      _currentState = e.state;
      _webSocket.add(jsonEncode(new OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
    });

    return null;
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

    if(track.loadType == "TRACK_LOADED") {
      var g = jsonEncode(new OpPlay(_guild, track.entity as Track).build());
      print(g);
      _webSocket.add(g);
      isPlaying = true;
    }
  }

  Future<Null> disconnect() async {
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, null, false, false)._build());
    await stop();
    _webSocket.add(jsonEncode(new SimpleOp("destroy", _guild).build()));
    isPlaying = false;
    isConnected = false;
    sub1 == null ? {} : sub1.cancel();
    sub2 == null ? {}:  sub2.cancel();
  }

  Future<Null> mute() async {
    _guild.shard.send("VOICE_STATE_UPDATE", new Opcode4(_guild, currentChannel, !_currentState.selfMute, _currentState.selfDeaf)._build());
  }

  Future<Null> pause() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new SimpleOp("pause", _guild).build()));
  }

  Future<Null> stop() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new SimpleOp("stop", _guild).build()));
  }

  Future<Null> seek(int position) async {
    _webSocket.add(jsonEncode(new OpSeek(_guild, position)));
  }

  Future<Null> setVolume(int volume) async {
    _webSocket.add(jsonEncode(new OpVolume(_guild, volume)));
  }

  Future<Null> finish() async {
    if(isConnected)
      await disconnect();
  }
}