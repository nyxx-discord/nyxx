part of nyxx.lavalink;

/// Represents Lavalink playable track
class Track extends Entity {
  /// Internal id of track.
  String id;

  /// Unique identifier
  String identifier;

  /// True if track be seeked
  bool isSeekable;

  /// Author of track
  String author;

  /// Length of track in milliseconds
  int length;

  /// True if track is stream of data
  bool isStream;

  /// Track position in milliseconds
  int position;

  /// Track title
  String title;

  /// Url to track
  String uri;

  /// Raw object returned by api
  Map<String, dynamic> raw;

  Track._new(this.raw) : super._new(0) {
    id = raw['track'] as String;
    identifier = raw['info']['identifier'] as String;
    isSeekable = raw['info']['isSeekable'] as bool;
    author = raw['info']['author'] as String;
    length = raw['info']['length'] as int;
    isStream = raw['info']['isStream'] as bool;
    position = raw['info']['position'] as int;
    title = raw['info']['title'] as String;
    uri = raw['info']['uri'] as String;
  }
}
