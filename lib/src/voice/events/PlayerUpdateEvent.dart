part of nyxx.voice;

class PlayerUpdateEvent {
  int position;
  int time;
  String guildId;

  Map<String, dynamic> raw;

  PlayerUpdateEvent._new(this.raw) {
    position = raw['state']['position'] as int;
    time = raw['state']['time'] as int;
    guildId = raw['guildId'] as String;
  }
}