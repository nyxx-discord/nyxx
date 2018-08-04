part of nyxx.voice;

class TrackExceptionEvent extends TrackError {
  String error;

  TrackExceptionEvent(Map<String, dynamic> raw) : super(raw) {
    track = raw['track'] as String;
  }
}