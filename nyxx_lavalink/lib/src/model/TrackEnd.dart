part of nyxx_lavalink;

/// Object sent when a track ends playing
class TrackEnd extends BaseEvent {
  /// Reason to the track to end
  final String reason;
  /// End type
  final String type;
  /// Base64 encoded track
  final String track;
  /// Guild where the track ended
  final Snowflake guildId;

  TrackEnd._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : reason = json["reason"] as String,
    type = json["type"] as String,
    track = json["track"] as String,
    guildId = Snowflake(json["guildId"] as String),
    super(client, node);
}
