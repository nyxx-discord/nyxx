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
}

/// Lavalink track object
class Track {
  /// Base64 encoded track
  late final String track;
  /// Optional information about the track
  late final TrackInfo? info;

  /// Create a new track instance
  Track(this.track, this.info);

  Track._fromJson(Map<String, dynamic> json) {
    if (json.containsKey("info")) {
      this.info = TrackInfo._fromJson(json["info"] as Map<String, dynamic>);
    }

    this.track = json["track"] as String;
  }
}

/// Track details
class TrackInfo {
  /// Track identifier
  late final String identifier;
  /// If the track is seekable (if it's a streaming it's not)
  late final bool seekable;
  /// The author of the track
  late final String author;
  /// The length of the track
  late final int length;
  /// Whether the track is a streaming or not
  late final bool stream;
  /// Position returned by lavalink
  late final int position;
  /// The title of the track
  late final String title;
  /// Url of the track
  late final String uri;

  TrackInfo._fromJson(Map<String, dynamic> json) {
    this.identifier = json["identifier"] as String;
    this.seekable = json["isSeekable"] as bool;
    this.author = json["author"] as String;
    this.length = json["length"] as int;
    this.stream = json["isStream"] as bool;
    this.position = json["position"] as int;
    this.title = json["title"] as String;
    this.uri = json["uri"] as String;
  }
}

/// Playlist info
class PlaylistInfo {
  /// Name of the playlist
  late final String? name;
  /// Currently selected track
  late final int? selectedTrack;

  PlaylistInfo._fromJson(Map<String, dynamic> json) {
    this.name = json["name"] as String?;
    this.selectedTrack = json["selectedTrack"] as int?;
  }
}

/// Object returned from lavalink when searching
class Tracks {
  /// Information about loaded playlist
  late final PlaylistInfo playlistInfo;
  /// Load type (track, playlist, etc)
  late final String loadType;
  /// Loaded tracks
  late final List<Track> tracks;
  /// Occurred exception (if occurred)
  late final LavalinkException? exception;
  
  Tracks._fromJson(Map<String, dynamic> json) {
    this.playlistInfo = PlaylistInfo._fromJson(json["playlistInfo"] as Map<String, dynamic>);
    this.loadType = json["loadType"] as String;
    this.tracks = (json["tracks"] as List<dynamic>).map((t) => Track._fromJson(t as Map<String, dynamic>)).toList();
    this.exception = json["exception"] == null ? null : LavalinkException._fromJson(json["exception"] as Map<String, dynamic>);
  }
}
