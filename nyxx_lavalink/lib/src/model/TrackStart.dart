part of nyxx_lavalink;

class TrackStart extends BaseEvent {
  /// Track start type (if its replaced or not the track)
  String startType;
  /// Base64 encoded track
  String track;
  /// Guild where the track started
  Snowflake guildId;

  TrackStart._fromJson(Nyxx client, Map<String, dynamic> json)
  : startType = json["type"] as String,
    track = json["track"] as String,
    guildId = Snowflake(json["guildId"]),
    super(client);
}