part of nyxx_lavalink;

/// Parameters to start playing a track
class PlayParameters {
  final Node _node;
  Track track;
  Snowflake guildId;
  bool replace;
  int startTime;
  int? endTime;

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

  /// Sets the requester of the track
  void setRequester(Snowflake requester) => this.requester = requester;
  /// Sets the channel id where this track was requested
  void setChannelId(Snowflake channelId) => this.channelId = channelId;

  /// Forces the song to start playing
  Future<void> startPlaying() async {
    if (this.endTime == null) {
      await _node._sendPayload("play", this.guildId, {
        "track": track.track,
        "noReplace": !this.replace,
        "startTime": this.startTime
      });
    } else {
      await _node._sendPayload("play", this.guildId, {
        "track": track.track,
        "noReplace": !this.replace,
        "startTime": this.startTime,
        "endTime": this.endTime
      });
    }
  }

  /// Puts the track on the queue and starts playing if necessary
  Future<void> queue() async {
    final player = _node.players[this.guildId];

    if(player == null) return;

    final queuedTrack = QueuedTrack._new(this.track, this.startTime, this.endTime, this.requester, this.channelId);

    if (player.nowPlaying == null && player.queue.isEmpty) {
      player.nowPlaying = queuedTrack;

      await this.startPlaying();
    }

    player.queue.add(queuedTrack);
  }
}