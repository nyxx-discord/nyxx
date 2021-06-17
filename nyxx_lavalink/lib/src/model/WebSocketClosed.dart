part of nyxx_lavalink;

/// Web socket closed event from lavalink
class WebSocketClosed extends BaseEvent {
  /// Type of close
  final String? type;
  /// Guild where the websocket has closed
  final Snowflake guildId;
  /// Close code
  final int code;
  /// Reason why the socket closed
  final String reason;
  /// If the connection was closed by discord
  final bool byRemote;

  WebSocketClosed._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : guildId = Snowflake(json["guildId"]),
    type = json["type"] as String?,
    code = json["code"] as int,
    reason = json["reason"] as String,
    byRemote = json["byRemote"] as bool,
    super(client, node);
}
