part of nyxx.voice;

class TrackStuckEvent extends TrackError {
  int thresholdMs;

  TrackStuckEvent(Map<String, dynamic> raw) : super(raw) {
    thresholdMs = raw['thresholdMs'] as int;
  }
}