part of nyxx.lavalink;

/// Emitted when track is stuck
class TrackStuckEvent extends TrackError {
  /// UNDOCUMENTED
  int thresholdMs;

  TrackStuckEvent(Map<String, dynamic> raw) : super(raw) {
    thresholdMs = raw['thresholdMs'] as int;
  }
}
