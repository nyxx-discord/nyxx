part of nyxx_lavalink;

/// Object sent when a track ends playing
class TrackEnd extends BaseEvent {
  /// Reason to the track to end
  late final String reason;
  /// End type
  late final String type;
  /// Base64 encoded track
  late final String track;
  /// Guild where the track ended
  late final Snowflake guildId;

  TrackEnd._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : super(client, node)
  {
    this.reason = json["reason"] as String;
    this.type = json["type"] as String;
    this.track = json["track"] as String;
    this.guildId = Snowflake(json["guildId"] as String);
  }
}
