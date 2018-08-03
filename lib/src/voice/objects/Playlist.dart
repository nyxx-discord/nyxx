part of nyxx.voice;

class Playlist extends Entity {
  String name;
  int selectedTrack;

  List<Track> tracks;

  Map<String, dynamic> raw;

  Playlist._new(this.raw) : super._new(1) {
    name = raw['playlistInfo']['name'] as String;
    selectedTrack = raw['playlistInfo']['selectedTrack'] as int;

    tracks = new List();
    raw['tracks'].forEach((dynamic o) {
      tracks.add(new Track._new(o as Map<String, dynamic>));
    });
  }
}