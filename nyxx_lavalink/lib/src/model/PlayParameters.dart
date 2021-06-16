part of nyxx_lavalink;

/// Parameters to start playing a track
class PlayParameters {
  final Node _node;
  /// The track to play
  Track track;
  /// The guild where the track will be played
  Snowflake guildId;
  /// Wether to replace the track or not
  bool replace;
  /// The time at where the track will start to play
  Duration startTime;
  /// The time at where the track will stop playing
  Duration? endTime;

  /// The requester of the track
  Snowflake? requester;

  /// The channel where this track was requested
  Snowflake? channelId;

  /// Create a new play parameters object, it is recommended to create this
  /// through [Node.play]
  PlayParameters(
      this._node,
      this.track,
      this.guildId,
      this.replace,
      this.startTime,
      this.endTime,
      this.requester,
      this.channelId
  );

  /// Forces the song to start playing
  void startPlaying() {
    if (this.endTime == null) {
      _node._sendPayload("play", this.guildId, {
        "track": track.track,
        "noReplace": !this.replace,
        "startTime": this.startTime.inMilliseconds
      });
    } else {
      _node._sendPayload("play", this.guildId, {
        "track": track.track,
        "noReplace": !this.replace,
        "startTime": this.startTime,
        "endTime": this.endTime!.inMilliseconds
      });
    }
  }

  /// Puts the track on the queue and starts playing if necessary
  void queue() {
    final player = _node.players[this.guildId];

    if(player == null) return;

    final queuedTrack = QueuedTrack._new(this.track, this.startTime, this.endTime, this.requester, this.channelId);

    // Whether if the node should start playing the track
    final shouldPlay = player.nowPlaying == null && player.queue.isEmpty;

    player.queue.add(queuedTrack);

    if(shouldPlay) {
      this._node._playNext(this.guildId);
    }
  }
}