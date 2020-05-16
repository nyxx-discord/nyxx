part of nyxx;

class OPCodes {
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
}

/// The client constants.
class Constants {
  static const String cdnHost = "discordapp.com";
  static const String host = "discord.com";
  static const String baseUri = "/api/v7";
  static const String version = "0.30.0";
  static const String repoUrl = "https://github.com/l7ssha/nyxx";
}
