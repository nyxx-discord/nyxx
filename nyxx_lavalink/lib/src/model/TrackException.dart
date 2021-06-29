part of nyxx_lavalink;

class TrackExceptionEvent extends BaseEvent {
  late final String track;
  late final String error;
  late final Snowflake guildId;

  TrackExceptionEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    this.track = json["track"] as String;
    this.error = json["error"] as String;
    this.guildId = Snowflake(json["guildId"]);
  }
}