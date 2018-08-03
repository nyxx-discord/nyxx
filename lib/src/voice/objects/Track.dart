part of nyxx.voice;

class Track extends Entity {
  String id;
  String identifier;
  bool isSeekable;
  String author;
  int length;
  bool isStream;
  int position;
  String title;
  String uri;

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