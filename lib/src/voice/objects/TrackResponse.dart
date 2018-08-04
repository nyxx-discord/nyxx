part of nyxx.voice;

/// Response of Lavalink api
class TrackResponse {
  /// Type of response
  String loadType;
  /// Represents [Track] or [Playlist]
  Entity entity;

  /// Raw object returned by api
  Map<String, dynamic> raw;

  TrackResponse._new(this.raw) {
    loadType = raw['loadType'] as String;

    if(raw['playlistInfo']['name'] == null) {
      entity = new Track._new(raw['tracks'].first as Map<String, dynamic>);
    }
    else {
      entity = new Playlist._new(raw);
    }
  }
}