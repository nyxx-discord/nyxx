part of nyxx_lavalink;

/// Web socket closed event from lavalink
class WebSocketClosedEvent extends BaseEvent {
  /// Type of close
  late final String? type;
  /// Guild where the websocket has closed
  late final Snowflake guildId;
  /// Close code
  late final int code;
  /// Reason why the socket closed
  late final String reason;
  /// If the connection was closed by discord
  late final bool byRemote;

  WebSocketClosedEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : super(client, node)
  {
    this.guildId = Snowflake(json["guildId"]);
    this.type = json["type"] as String?;
    this.code = json["code"] as int;
    this.reason = json["reason"] as String;
    this.byRemote = json["byRemote"] as bool;
  }
}
