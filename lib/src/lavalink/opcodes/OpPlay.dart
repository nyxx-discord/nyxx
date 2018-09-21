part of nyxx.voice;

/// Opcode for playing new track
class _OpPlay {
  String _op = "play";
  Guild _guildId;
  Track _track;
  String startTime;
  String endTime;

  _OpPlay(this._guildId, this._track, {this.startTime, this.endTime});

  Map<String, dynamic> build() {
    return {
      "op": _op,
      "guildId": _guildId.id.toString(),
      "track": _track.id,
      "startTime": startTime != null ? startTime : 0,
      "endTime": endTime != null ? endTime : _track.length
    };
  }
}
