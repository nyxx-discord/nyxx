part of nyxx.voice;

class OpPlay {
  String op = "play";
  Guild guildId;
  Track track;
  String startTime;
  String endTime;

  OpPlay(this.guildId, this.track, {this.startTime, this.endTime});

  Map<String, dynamic> build() {
    return {
      "op": op,
      "guildId": guildId.id.toString(),
      "track": track.id,
      "startTime": startTime != null ? startTime : 0,
      "endTime": endTime != null ? endTime : track.length
    };
  }
}