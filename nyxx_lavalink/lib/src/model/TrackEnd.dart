part of nyxx_lavalink;

/// Object sent when a track ends playing
class TrackEndEvent extends BaseEvent {
  /// Reason to the track to end
  late final String reason;
  /// Base64 encoded track
  late final String track;
  /// Guild where the track ended
  late final Snowflake guildId;

  TrackEndEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    this.reason = json["reason"] as String;
    this.track = json["track"] as String;
    this.guildId = Snowflake(json["guildId"] as String);
  }
}
