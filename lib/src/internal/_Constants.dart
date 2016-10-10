part of discord;

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
}

/// The client constants.
class _Constants {
  static const String host = "https://discordapp.com/api";

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
    "HEARTBEAT_ACK": 11
  };

  /// The permission bits.
  static const Map<String, int> permissions = const <String, int>{
    "CREATE_INSTANT_INVITE": 1 << 0,
    "KICK_MEMBERS": 1 << 1,
    "BAN_MEMBERS": 1 << 2,
    "ADMINISTRATOR": 1 << 3,
    "MANAGE_CHANNELS": 1 << 4,
    "MANAGE_GUILD": 1 << 5,
    "READ_MESSAGES": 1 << 10,
    "SEND_MESSAGES": 1 << 11,
    "SEND_TTS_MESSAGES": 1 << 12,
    "MANAGE_MESSAGES": 1 << 13,
    "EMBED_LINKS": 1 << 14,
    "ATTACH_FILES": 1 << 15,
    "READ_MESSAGE_HISTORY": 1 << 16,
    "MENTION_EVERYONE": 1 << 17,
    "EXTERNAL_EMOJIS": 1 << 18,
    "CONNECT": 1 << 20,
    "SPEAK": 1 << 21,
    "MUTE_MEMBERS": 1 << 22,
    "DEAFEN_MEMBERS": 1 << 23,
    "MOVE_MEMBERS": 1 << 24,
    "USE_VAD": 1 << 25,
    "CHANGE_NICKNAME": 1 << 26,
    "MANAGE_NICKNAMES": 1 << 27,
    "MANAGE_ROLES_OR_PERMISSIONS": 1 << 28,
    "MANAGE_WEBHOOKS": 1 << 29,
    "MANAGE_EMOJIS": 1 << 30
  };
}
