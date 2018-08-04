part of nyxx.voice;

class TrackError {
  String track;

  Map<String, dynamic> raw;

  TrackError(this.raw) {
    track = raw['track'] as String;
  }
}