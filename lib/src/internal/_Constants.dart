part of nyxx;

class _OPCodes {
  static const int dispatch = 0;
  static const int heartbeat = 1;
  static const int identify = 2;
  static const int statusUpdate = 3;
  static const int voiceStateUpdate = 4;
  static const int voiceGuildPing = 5;
  static const int resume = 6;
  static const int reconnect = 7;
  static const int requesGuildMembers = 8;
  static const int invalidSession = 9;
  static const int hello = 10;
  static const int heartbeatAck = 11;
  static const int guildSync = 12;
}

/// The client constants.
class _Constants {
  static const String host = "discordapp.com";
  static const String baseUri = "/api/v6";
  static const String version = "0.22.0";

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
