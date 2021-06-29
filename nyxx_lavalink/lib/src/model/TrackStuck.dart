part of nyxx_lavalink;

/// Object sent when a track gets stuck when playing
class TrackStuckEvent extends BaseEvent {
  /// Base64 encoded track
  late final String track;
  /// The wait threshold that was exceeded for this event to trigger
  late final int thresholdMs;
  /// Guild where the track got stuck
  late final Snowflake guildId;

  TrackStuckEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    this.track = json["track"] as String;
    this.thresholdMs = json["thresholdMs"] as int;
    this.guildId = Snowflake(json["guildId"] as String);
  }
}