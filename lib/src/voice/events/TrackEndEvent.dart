part of nyxx.voice;

/// Event emitted when track ends/stop/etc
class TrackEndEvent extends TrackError {
  /// Reason of stopping track
  String reason;

  TrackEndEvent(Map<String, dynamic> raw) : super(raw) {
    reason = raw['reason'] as String;
  }
}