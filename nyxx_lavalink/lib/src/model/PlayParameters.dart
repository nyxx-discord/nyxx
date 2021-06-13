part of nyxx_lavalink;

class PlayParameters {
  Node _node;
  Track track;
  bool replace;
  int startTime = 0;
  int? endTime;
  Snowflake guildId;

  PlayParameters._new(this._node, this.track, this.guildId) : replace = false;

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

    final queuedTrack = QueuedTrack(this.track, startTime, this.endTime);

    if (player.nowPlaying == null && player.queue.isEmpty) {
      player.nowPlaying = queuedTrack;

      await this.startPlaying();
    }

    player.queue.add(queuedTrack);
  }
}