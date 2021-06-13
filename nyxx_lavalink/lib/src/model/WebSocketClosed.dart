part of nyxx_lavalink;


class WebSocketClosed extends BaseEvent {
  /// Type of close
  String? type;
  /// Guild where the websocket has closed
  Snowflake guildId;
  /// Close code
  int code;
  /// Reason why the socket closed
  String reason;
  /// If the connection was closed by discord
  bool byRemote;

  WebSocketClosed._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : guildId = Snowflake(json["guildId"]),
    type = json["type"] as String?,
    code = json["code"] as int,
    reason = json["reason"] as String,
    byRemote = json["byRemote"] as bool,
    super(client, node);
}