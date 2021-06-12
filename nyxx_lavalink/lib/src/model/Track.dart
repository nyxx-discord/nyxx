part of nyxx_lavalink;

/// Represents a track already on a player queue
class QueuedTrack {
  /// The actual track
  Track track;
  /// Where should start lavalink playing the track
  int startTime;
  /// If the track should stop playing before finish and where
  int? endTime;

  /// Create a new QueuedTrack instance
  QueuedTrack(this.track, this.startTime, this.endTime);
}

/// Lavalink track object
class Track {
  /// Base64 encoded track
  String track;
  /// Optional information about the track
  TrackInfo? info;

  /// Create a new track instance
  Track(this.track, this.info);

  factory Track._fromJson(Map<String, dynamic> json) {
    TrackInfo? trackInfo;

    if (json.containsKey("info")) trackInfo = TrackInfo._fromJson(json["info"] as Map<String, dynamic>);

    return Track(json["track"] as String, trackInfo);
  }
}

/// Track details
class TrackInfo {
  /// Track identifier
  String identifier;
  /// If the track is seekable (if it's a streaming it's not)
  bool seekable;
  /// The author of the track
  String author;
  /// The length of the track
  int length;
  /// Whether the track is a streaming or not
  bool stream;
  /// Position returned by lavalink
  int position;
  /// The title of the track
  String title;
  /// Url of the track
  String uri;

  TrackInfo._fromJson(Map<String, dynamic> json)
  : identifier = json["identifier"] as String,
    seekable = json["isSeekable"] as bool,
    author = json["author"] as String,
    length = json["length"] as int,
    stream = json["isStream"] as bool,
    position = json["position"] as int,
    title = json["title"] as String,
    uri = json["uri"] as String;
}

/// Playlist info
class PlaylistInfo {
  /// Name of the playlist
  String? name;
  /// Currently selected track
  int? selectedTrack;

  PlaylistInfo._fromJson(Map<String, dynamic> json)
  : name = json["name"] as String?, selectedTrack = json["selectedTrack"] as int?;
}

/// Object returned from lavalink when searching
class Tracks {
  /// Information about loaded playlist
  PlaylistInfo playlistInfo;
  /// Load type (track, playlist, etc)
  String loadType;
  /// Loaded tracks
  List<Track> tracks;
  /// Occurred exception (if occurred)
  LavalinkException? exception;
  
  Tracks._fromJson(Map<String, dynamic> json)
  : playlistInfo = PlaylistInfo._fromJson(json["playlistInfo"] as Map<String, dynamic>), 
    loadType = json["loadType"] as String,
    tracks = (json["tracks"] as List<dynamic>).map((t) => Track._fromJson(t as Map<String, dynamic>)).toList(),
    exception = json["exception"] == null ? null : LavalinkException._fromJson(json["exception"] as Map<String, dynamic>);
}