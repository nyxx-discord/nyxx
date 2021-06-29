part of nyxx_lavalink;

/// Object sent when a track gets an exception while playing
class TrackExceptionEvent extends BaseEvent {
  /// Base64 encoded track
  late final String track;
  /// The occurred error
  late final LavalinkException exception;
  /// Guild id where the track got an exception
  late final Snowflake guildId;

  TrackExceptionEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    this.track = json["track"] as String;
    this.exception = LavalinkException._fromJson(json);
    this.guildId = Snowflake(json["guildId"]);
  }
}
