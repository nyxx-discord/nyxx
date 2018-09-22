part of nyxx.lavalink;

/// Provides abstraction for TrakcErrors
class TrackError {
  /// Track id
  String track;

  Map<String, dynamic> raw;

  TrackError(this.raw) {
    track = raw['track'] as String;
  }
}
