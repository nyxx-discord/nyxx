part of nyxx.voice;

/// Manages voice connection for guild. There can be only one player for [Guild]
class Player {
  /// True if player is connecte
  bool isConnected = false;
  /// True if player is playing something
  bool isPlaying = false;
  /// Current [VoiceChannel] player is in
  VoiceChannel currentChannel;
  /// Current playing track
  Track currentTrack;

  Guild _guild;
  Client _client;
  Uri _restPath;

  var _sub1, _sub2;

  dynamic _rawEvent;
  VoiceState _currentState;

  w_transport.WebSocket _webSocket;

  StreamController<TrackError> _onTrackError;
  /// Emitted when Lavalink TrackError occurs.
  /// [Read here](https://github.com/Frederikam/Lavalink/blob/master/IMPLEMENTATION.md#incoming-messages)
  Stream<TrackError> onTrackError;

  StreamController<PlayerUpdateEvent> _onPlayerUpdate;
  /// Emits Position information about a player. Includes unix timestamp.
  Stream<PlayerUpdateEvent> onPlayerUpdate;

  Player._new(this._guild, this._client, this._webSocket, this._restPath);

  /// Connects to channel.
  /// Remember to await this methods - thread can be locked forever.
  Future<Null> connect(VoiceChannel channel) async {
    isConnected = true;
    currentChannel = channel;

    _onPlayerUpdate = new StreamController.broadcast();
    onPlayerUpdate = _onPlayerUpdate.stream;

    _onTrackError = new StreamController.broadcast();
    onTrackError = _onTrackError.stream;

    _guild.shard.send("VOICE_STATE_UPDATE", new _Opcode4(_guild, channel, false, false)._build());

    _currentState = (await _client.onVoiceStateUpdate.first).state;
    _rawEvent =  (await _client.onVoiceServerUpdate.first).raw;

    var s = jsonEncode(new _OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build());
    print(s);
    _webSocket.add(s);

    _sub1 = _client.onVoiceServerUpdate.where((e) => e.guild.id.toString() == _guild.id.toString()).listen((e) {
      _rawEvent = e.raw;
      _webSocket.add(jsonEncode(new _OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
    });

    _sub2 = _client.onVoiceStateUpdate.where((e) {
      if(e.state.channel != null)
        if(e.state.channel.id.toString() != currentChannel.id.toString())
          return false;

      return e.state.user.id.toString() == _client.user.id.toString();
    }).listen((e) {
      _currentState = e.state;
      _webSocket.add(jsonEncode(new _OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent).build()));
    });

    return null;
  }

  /// Changes channel to other. Allows to optionally set mute and deafen.
  Future<Null> changeChannel(VoiceChannel channel, {bool muted: false, bool deafen: false}) {
    currentChannel = channel;
    _guild.shard.send("VOICE_STATE_UPDATE", new _Opcode4(_guild, channel, muted, deafen)._build());
  }

  /// Resolves url to Lavalink Track
  Future<TrackResponse> resolve(String hash) async {
    var req = w_transport.JsonRequest()
      ..uri = _restPath
      ..path = "/loadtracks"
      ..headers = { "Authorization": "password" }
      ..queryParameters = { "identifier" : hash };

    var res = await req.send("GET");
    if(res.status != 200)
      throw new Exception("Cannot comunicate with lavalink via http");

    var r = res.body.asJson() as Map<String, dynamic>;
    return new TrackResponse._new(r);
  }

  /// Plays track on currently connected channel
  Future<bool> play(Entity track) async {
    if(track is Track)
      currentTrack = track;
    else if(track is Playlist) currentTrack = track.tracks.first;

    _webSocket.add(jsonEncode(new _OpPlay(_guild, currentTrack).build()));
    isPlaying = true;
    return true;
  }

  /// Disconnect from channel. Closes all unneeded connections.
  Future<Null> disconnect() async {
    _guild.shard.send("VOICE_STATE_UPDATE", new _Opcode4(_guild, null, false, false)._build());
    await stop();
    _webSocket.add(jsonEncode(new _SimpleOp("destroy", _guild)._build()));
    isPlaying = false;
    isConnected = false;
    _sub1 == null ? {} : _sub1.cancel();
    _sub2 == null ? {}:  _sub2.cancel();
  }

  /// Toggles mute status.
  Future<Null> toggleMute() async {
    if(_currentState.selfMute)
      _webSocket.add(jsonEncode(new _OpPause(_guild , false).build()));
    else
      _webSocket.add(jsonEncode(new _OpPause(_guild , true).build()));

    _guild.shard.send("VOICE_STATE_UPDATE", new _Opcode4(_guild, currentChannel, !_currentState.selfMute, _currentState.selfDeaf)._build());
  }

  /// Pauses currently played track
  Future<Null> pause() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new _SimpleOp("pause", _guild)._build()));
  }

  /// Stops track playback
  Future<Null> stop() async {
    isPlaying = false;
    _webSocket.add(jsonEncode(new _SimpleOp("stop", _guild)._build()));
  }

  /// Seeks track to position in milliseconds
  Future<Null> seek(int position) async {
    _webSocket.add(jsonEncode(new _OpSeek(_guild, position)));
  }

  /// Set player volume. Volume may range from 0 to 1000. 100 is default.
  Future<Null> setVolume(int volume) async {
    _webSocket.add(jsonEncode(new _OpVolume(_guild, volume)));
  }

  Future<Null> _finish() async {
    if(isConnected)
      await disconnect();
  }
}