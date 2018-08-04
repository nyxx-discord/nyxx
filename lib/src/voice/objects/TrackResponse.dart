part of nyxx.voice;

class TrackResponse {
  String loadType;
  Entity entity;

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