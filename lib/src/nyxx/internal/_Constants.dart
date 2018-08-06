part of nyxx;

class _OPCodes {
  static const int DISPATCH = 0;
  static const int HEARTBEAT = 1;
  static const int IDENTIFY = 2;
  static const int STATUS_UPDATE = 3;
  static const int VOICE_STATE_UPDATE = 4;
  static const int VOICE_GUILD_PING = 5;
  static const int RESUME = 6;
  static const int RECONNECT = 7;
  static const int REQUEST_GUILD_MEMBER = 8;
  static const int INVALID_SESSION = 9;
  static const int HELLP = 10;
  static const int HEARBEAT_ACK = 11;
  static const int GUILD_SYNC = 12;
}

/// The client constants.
class _Constants {
  static const String host = "discordapp.com";
  static const String baseUri = "/api/v6";
  static const String version = "0.24.0";

  /// The gateway OP codes.
  static const Map<String, int> opCodes = const <String, int>{
    "DISPATCH": 0,
    "HEARTBEAT": 1,
    "IDENTIFY": 2,
    "STATUS_UPDATE": 3,
    "VOICE_STATE_UPDATE": 4,
    "VOICE_GUILD_PING": 5,
    "RESUME": 6,
    "RECONNECT": 7,
    "REQUEST_GUILD_MEMBERS": 8,
    "INVALID_SESSION": 9,
    "HELLO": 10,
    "HEARTBEAT_ACK": 11,
    "GUILD_SYNC": 12
  };
}
