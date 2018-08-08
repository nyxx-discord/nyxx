part of nyxx.voice;

/// Emitted when track generates exception
class TrackExceptionEvent extends TrackError {
  /// Error message
  String error;

  TrackExceptionEvent(Map<String, dynamic> raw) : super(raw) {
    track = raw['track'] as String;
  }
}