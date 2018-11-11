part of nyxx.lavalink;

/// Manages voice connection for guild. There can be only one player for [Guild]
class Player {
  /// True if player is connected
  bool isConnected = false;

  /// True if player is playing something
  //bool isPlaying = false;
  /// Current [VoiceChannel] player is in
  VoiceChannel currentChannel;

  /// Current playing track
  Track currentTrack;

  /// Emitted when Lavalink TrackError occurs.
  /// [Read here](https://github.com/Frederikam/Lavalink/blob/master/IMPLEMENTATION.md#incoming-messages)
  Stream<TrackError> onTrackError;

  /// Emits Position information about a player. Includes unix timestamp.
  Stream<PlayerUpdateEvent> onPlayerUpdate;

  StreamController<TrackError> _onTrackError;
  StreamController<PlayerUpdateEvent> _onPlayerUpdate;

  Guild _guild;

  var _sub1, _sub2;
  dynamic _rawEvent;
  VoiceState _currentState;

  Player._new(this._guild);

  /// Connects to channel.
  /// Remember to await this methods - thread can be locked forever.
  Future<void> connect(VoiceChannel channel) async {
    isConnected = true;
    currentChannel = channel;

    _onPlayerUpdate = StreamController.broadcast();
    onPlayerUpdate = _onPlayerUpdate.stream;

    _onTrackError = StreamController.broadcast();
    onTrackError = _onTrackError.stream;

    _guild.shard.send(
        "VOICE_STATE_UPDATE", _Opcode4(_guild, channel, false, false)._build());

    _currentState = (await _manager.client.onVoiceStateUpdate.first).state;
    _rawEvent = (await _manager.client.onVoiceServerUpdate.first).raw;

    var s = jsonEncode(
        _OpVoiceUpdate(_guild.id.toString(), _currentState.sessionId, _rawEvent)
            .build());
    print(s);
    _manager._webSocket.add(s);

    _sub1 = _manager.client.onVoiceServerUpdate
        .where((e) => e.guild.id == _guild.id)
        .listen((e) {
      _rawEvent = e.raw;
      _manager._webSocket.add(jsonEncode(_OpVoiceUpdate(
              _guild.id.toString(), _currentState.sessionId, _rawEvent)
          .build()));
    });

    _sub2 = _manager.client.onVoiceStateUpdate.where((e) {
      if (e.state.channel != null) if (e.state.channel.id != currentChannel.id)
        return false;

      return e.state.user.id == _manager.client.self.id;
    }).listen((e) {
      _currentState = e.state;
      _manager._webSocket.add(jsonEncode(_OpVoiceUpdate(
              _guild.id.toString(), _currentState.sessionId, _rawEvent)
          .build()));
    });
  }

  /// Changes channel to other. Allows to optionally set mute and deafen.
  Future<void> changeChannel(VoiceChannel channel,
      {bool muted = false, bool deafen = false}) {
    currentChannel = channel;
    _guild.shard.send("VOICE_STATE_UPDATE",
        _Opcode4(_guild, channel, muted, deafen)._build());
  }

  /// Resolves url to Lavalink Track
  Future<TrackResponse> resolve(String hash) async {
    var uri = _manager._restPath
        .replace(path: "/loadtracks", queryParameters: {"identifier": hash});

    var req = transport.Request()..uri = uri;

    req.headers["Authorization"] = _manager._password;

    var res = await req.send("GET");
    if (res.status != 200)
      return Future.error(
          Exception("Cannot comunicate with lavalink via http"));

    var r = res.body.asJson();
    return TrackResponse._new(r as Map<String, dynamic>);
  }

  /// Plays track on currently connected channel
  Future<bool> play(Entity track) async {
    if (track is Track)
      currentTrack = track;
    else if (track is Playlist) currentTrack = track.tracks.first;

    _manager._webSocket.add(jsonEncode(_OpPlay(_guild, currentTrack).build()));
    return true;
  }

  /// Disconnect from channel. Closes all unneeded connections.
  Future<void> disconnect() async {
    _guild.shard.send(
        "VOICE_STATE_UPDATE", _Opcode4(_guild, null, false, false)._build());
    await stop();
    _manager._webSocket.add(jsonEncode(_SimpleOp("destroy", _guild)._build()));
    isConnected = false;
    if (_sub1 == null) _sub1.cancel();
    if (_sub2 == null) _sub2.cancel();
  }

  /// Toggles mute status.
  Future<void> toggleMute() async {
    var op;
    if (_currentState.selfMute)
      op = _OpPause(_guild, false).build();
    else
      op = _OpPause(_guild, true).build();

    _manager._webSocket.add(jsonEncode(op));
    _guild.shard.send(
        "VOICE_STATE_UPDATE",
        _Opcode4(_guild, currentChannel, !_currentState.selfMute,
                _currentState.selfDeaf)
            ._build());
  }

  /// Pauses currently played track
  Future<void> pause() async =>
      _manager._webSocket.add(jsonEncode(_SimpleOp("pause", _guild)._build()));

  /// Stops track playback
  Future<void> stop() async =>
      _manager._webSocket.add(jsonEncode(_SimpleOp("stop", _guild)._build()));

  /// Seeks track to position in milliseconds
  Future<void> seek(int position) async =>
      _manager._webSocket.add(jsonEncode(_OpSeek(_guild, position)));

  /// Set player volume. Volume may range from 0 to 1000. 100 is default.
  Future<void> setVolume(int volume) async =>
      _manager._webSocket.add(jsonEncode(_OpVolume(_guild, volume).build()));

  Future<void> _finish() async {
    if (isConnected) return disconnect();
  }
}
