part of nyxx.voice;

/// Emitted when track is stuck
class TrackStuckEvent extends TrackError {
  /// UNDOCUMENTED
  int thresholdMs;

  TrackStuckEvent(Map<String, dynamic> raw) : super(raw) {
    thresholdMs = raw['thresholdMs'] as int;
  }
}
