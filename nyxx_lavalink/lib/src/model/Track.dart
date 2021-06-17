part of nyxx_lavalink;

/// Represents a track already on a player queue
class QueuedTrack {
  /// The actual track
  final Track track;
  /// Where should start lavalink playing the track
  final Duration startTime;
  /// If the track should stop playing before finish and where
  final Duration? endTime;

  /// The requester of the track
  final Snowflake? requester;

  /// The channel where this track was requested
  final Snowflake? channelId;

  /// Create a new QueuedTrack instance
  QueuedTrack._new(this.track, this.startTime, this.endTime, this.requester, this.channelId);

  @override
  String toString() =>
      "<QueuedTrack title=${this.track.info?.title} identifier=${this.track.info?.identifier}>";
}

/// Lavalink track object
class Track {
  /// Base64 encoded track
  final String track;
  /// Optional information about the track
  final TrackInfo? info;

  /// Create a new track instance
  Track(this.track, this.info);

  factory Track._fromJson(Map<String, dynamic> json) {
    TrackInfo? trackInfo;

    if (json.containsKey("info")) {
      trackInfo = TrackInfo._fromJson(json["info"] as Map<String, dynamic>);
    }

    return Track(json["track"] as String, trackInfo);
  }
}

/// Track details
class TrackInfo {
  /// Track identifier
  final String identifier;
  /// If the track is seekable (if it's a streaming it's not)
  final bool seekable;
  /// The author of the track
  final String author;
  /// The length of the track
  final int length;
  /// Whether the track is a streaming or not
  final bool stream;
  /// Position returned by lavalink
  final int position;
  /// The title of the track
  final String title;
  /// Url of the track
  final String uri;

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
  final String? name;
  /// Currently selected track
  final int? selectedTrack;

  PlaylistInfo._fromJson(Map<String, dynamic> json)
  : name = json["name"] as String?,
    selectedTrack = json["selectedTrack"] as int?;
}

/// Object returned from lavalink when searching
class Tracks {
  /// Information about loaded playlist
  final PlaylistInfo playlistInfo;
  /// Load type (track, playlist, etc)
  final String loadType;
  /// Loaded tracks
  final List<Track> tracks;
  /// Occurred exception (if occurred)
  final LavalinkException? exception;
  
  Tracks._fromJson(Map<String, dynamic> json)
  : playlistInfo = PlaylistInfo._fromJson(json["playlistInfo"] as Map<String, dynamic>), 
    loadType = json["loadType"] as String,
    tracks = (json["tracks"] as List<dynamic>).map((t) => Track._fromJson(t as Map<String, dynamic>)).toList(),
    exception = json["exception"] == null ? null : LavalinkException._fromJson(json["exception"] as Map<String, dynamic>);
}
