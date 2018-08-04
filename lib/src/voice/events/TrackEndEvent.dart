part of nyxx.voice;

class TrackEndEvent extends TrackError {
  String reason;

  TrackEndEvent(Map<String, dynamic> raw) : super(raw) {
    reason = raw['reason'] as String;
  }
}