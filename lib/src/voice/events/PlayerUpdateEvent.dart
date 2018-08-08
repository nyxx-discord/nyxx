part of nyxx.voice;

/// Represents player update incoming from Lavalink
class PlayerUpdateEvent {
  /// Actual song position in millis
  int position;
  /// Total length of track
  int time;
  /// Guild for track is playing for
  String guildId;

  /// Raw object returned by WS
  Map<String, dynamic> raw;

  PlayerUpdateEvent._new(this.raw) {
    position = raw['state']['position'] as int;
    time = raw['state']['time'] as int;
    guildId = raw['guildId'] as String;
  }
}