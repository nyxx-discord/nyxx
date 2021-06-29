part of nyxx_lavalink;

/// Object sent when a track gets stuck when playing
class TrackStuckEvent extends BaseEvent {

  late final String track;
  late final int thresholdMs;
  late final Snowflake guildId;

  TrackStuckEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    this.track = json["track"] as String;
    this.thresholdMs = json["thresholdMs"] as int;
    this.guildId = Snowflake(json["guildId"] as String);
  }
}