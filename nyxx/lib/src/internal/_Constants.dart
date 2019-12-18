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
  static const int requestGuildMember = 8;
  static const int invalidSession = 9;
  static const int hello = 10;
  static const int heartbeatAck = 11;
  static const int guildSync = 12;

  static int matchOpCode(String op) {
    switch (op) {
      case "DISPATCH":
        return dispatch;
      case "HEARTBEAT":
        return heartbeat;
      case "IDENTIFY":
        return identify;
      case "STATUS_UPDATE":
        return statusUpdate;
      case "VOICE_STATE_UPDATE":
        return voiceStateUpdate;
      case "VOICE_GUILD_PING":
        return voiceGuildPing;
      case "RESUME":
        return resume;
      case "RECONNECT":
        return reconnect;
      case "REQUEST_GUILD_MEMBERS":
        return requestGuildMember;
      case "INVALID_SESSION":
        return invalidSession;
      case "HELLO":
        return hello;
      case "HEARTBEAT_ACK":
        return heartbeatAck;
      case "GUILD_SYNC":
        return guildSync;
      default:
        throw Exception("Invalid opCode: $op");
    }
  }
}

/// The client constants.
class _Constants {
  static const String host = "discordapp.com";
  static const String baseUri = "/api/v7";
  static const String version = "0.30.0";
  static const String repoUrl = "https://github.com/l7ssha/nyxx";
}
