/// Gateway constants
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
  /// Discord CDN host
  static const String cdnHost = "discordapp.com";

  /// Url for cdn host
  static const String cdnUrl = "https://cdn.${Constants.cdnHost}";

  /// Discord API host
  static const String host = "discord.com";

  /// Base API uri
  static const String baseUri = "/api/v$apiVersion";

  /// Version of API
  static const int apiVersion = 10;

  /// Version of Nyxx
  static const String version = "5.1.2";

  /// Url to Nyxx repo
  static const String repoUrl = "https://github.com/nyxx-discord/nyxx";

  /// Returns [Uri] to gateway
  static Uri gatewayUri(String gatewayHost, bool useCompression, [Encoding encoding = Encoding.json]) {
    var uriString = "$gatewayHost?v=$apiVersion&encoding=${encoding.name}";

    if (useCompression) {
      uriString += "&compress=zlib-stream";
    }

    return Uri.parse(uriString);
  }
}

class CdnConstants {
  /// The allowed extensions for the CDN urls.
  static const List<String> allowedExtensions = ['webp', 'png', 'gif', 'jpg', 'jpeg'];

  /// The allowed extensions for the stickers.
  static const List<String> allowedExtensionsForSickers = ['png', 'json'];

  /// The allowed sizes.
  static const List<int> allowedSizes = [16, 32, 48, 64, 80, 96, 128, 160, 240, 256, 320, 480, 512, 640, 1024, 1280, 1536, 2048, 3072, 4096];
}

/// The type of encoding to receive/send payloads to discord.
enum Encoding {
  /// ETF (External Term Format) encoding
  /// It's more performant on a ton of servers, use it if you want to optimise your bot scaling.
  etf,

  /// JSON (JavaScript Object Notation) is an universal data transferring model,
  /// it can be used on production too.
  json
}
