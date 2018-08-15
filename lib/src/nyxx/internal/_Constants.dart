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

  static int matchOpCode(String op) {
    switch (op) {
      case "DISPATCH":
        return DISPATCH;
      case "HEARTBEAT":
        return HEARTBEAT;
      case "IDENTIFY":
        return IDENTIFY;
      case "STATUS_UPDATE":
        return STATUS_UPDATE;
      case "VOICE_STATE_UPDATE":
        return VOICE_STATE_UPDATE;
      case "VOICE_GUILD_PING":
        return VOICE_GUILD_PING;
      case "RESUME":
        return RESUME;
      case "RECONNECT":
        return RECONNECT;
      case "REQUEST_GUILD_MEMBERS":
        return REQUEST_GUILD_MEMBER;
      case "INVALID_SESSION":
        return INVALID_SESSION;
      case "HELLO":
        return HELLP;
      case "HEARTBEAT_ACK":
        return HEARBEAT_ACK;
      case "GUILD_SYNC":
        return GUILD_SYNC;
      default:
        throw new Exception("Invalid opCode: $op");
    }
  }
}

/// The client constants.
class _Constants {
  static const String host = "discordapp.com";
  static const String baseUri = "/api/v7";
  static const String version = "1.0.0";
  static const String repoUrl = "https://github.com/l7ssha/nyxx";
}
