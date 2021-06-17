part of nyxx_lavalink;

/// Object sent when a track starts playing
class TrackStartEvent extends BaseEvent {
  /// Track start type (if its replaced or not the track)
  late final String startType;
  /// Base64 encoded track
  late final String track;
  /// Guild where the track started
  late final Snowflake guildId;

  TrackStartEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : super(client, node)
  {
    this.startType = json["type"] as String;
    this.track = json["track"] as String;
    this.guildId = Snowflake(json["guildId"]);
  }
}
