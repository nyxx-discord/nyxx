part of nyxx.lavalink;

/// Emitted when track generates exception
class TrackExceptionEvent extends TrackError {
  /// Error message
  String error;

  TrackExceptionEvent(Map<String, dynamic> raw) : super(raw) {
    track = raw['track'] as String;
  }
}
