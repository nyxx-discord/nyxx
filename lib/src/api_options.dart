import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/intents.dart';
import 'package:nyxx/src/utils/flags.dart';

/// Options for connecting to the Discord API.
abstract class ApiOptions {
  /// The version of nyxx used in [defaultUserAgent].
  static const nyxxVersion = '6.0.0-dev.1';

  /// The URL to the nyxx repository used in [defaultUserAgent].
  static const nyxxRepositoryUrl = 'https://github.com/nyxx-discord/nyxx';

  /// The default value for the `User-Agent` header for bots made with nyxx.
  static const defaultUserAgent = 'Nyxx ($nyxxRepositoryUrl, $nyxxVersion)';

  /// The host at which the API can be found.
  ///
  /// This is always `discord.com`.
  String get host;

  /// The base URI relative to the [host] where the API can be found.
  String get baseUri;

  /// The version of the API to use.
  int get apiVersion;

  /// The value of the `Authorization` header to use when authenticating requests.
  String get authorizationHeader;

  /// The value of the `User-Agent` header to send with each request.
  String get userAgent;

  /// The host at which the CDN can be found.
  ///
  /// This is always `cdn.discordapp.com`.
  String get cdnHost;
}

/// Options for connecting to the Discord API to make HTTP requests with a bot token.
class RestApiOptions implements ApiOptions {
  /// The token to use.
  final String token;

  @override
  final String host = 'discord.com';

  @override
  final int apiVersion = 10;

  @override
  String get baseUri => '/api/v$apiVersion';

  @override
  String get authorizationHeader => 'Bot $token';

  @override
  final String userAgent;

  @override
  String get cdnHost => 'cdn.discordapp.com';

  /// Create a new [RestApiOptions].
  RestApiOptions({required this.token, this.userAgent = ApiOptions.defaultUserAgent});
}

/// Options for connecting to the Discord API for making HTTP requests and connecting to the Gateway
/// with a bot token.
class GatewayApiOptions extends RestApiOptions {
  /// The intents to use.
  final Flags<GatewayIntents> intents;

  /// The format of the Gateway payloads.
  final GatewayPayloadFormat payloadFormat;

  /// The compression to use on the Gateway connection.
  final GatewayCompression compression;

  /// The IDs of the shards to spawn by this client.
  ///
  /// If this is not set, the client spawns all shards from `0` to [totalShards].
  final List<int>? shards;

  /// The total number of shards in the current session.
  ///
  /// If this is not set, the client will use the recommended shard count from Discord.
  final int? totalShards;

  /// The threshold after which guilds are considered large in the Gateway.
  final int? largeThreshold;

  /// The presence the client will set after first connecting to the Gateway.
  final PresenceBuilder? initialPresence;

  /// The query parameters to append to the Gateway connection URL.
  Map<String, String> get gatewayConnectionOptions => {
        'v': apiVersion.toString(),
        'encoding': payloadFormat.value,
        if (compression == GatewayCompression.transport) 'compress': 'zlib-stream',
      };

  /// Create a new [GatewayApiOptions].
  GatewayApiOptions({
    required super.token,
    super.userAgent,
    required this.intents,
    this.payloadFormat = GatewayPayloadFormat.json,
    this.compression = GatewayCompression.transport,
    this.shards,
    this.totalShards,
    this.largeThreshold,
    this.initialPresence,
  });
}

/// The format of Gateway payloads.
enum GatewayPayloadFormat {
  /// Payloads are sent as JSON.
  json._('json'),

  /// Payloads are sent as ETF.
  etf._('etf');

  /// The value of this [GatewayPayloadFormat].
  final String value;

  const GatewayPayloadFormat._(this.value);

  @override
  String toString() => value;
}

/// The compression of a Gateway connection.
enum GatewayCompression {
  /// No compression is used.
  none,

  /// The entire connection is compressed.
  transport,

  /// Each packet is individually compressed.
  ///
  /// Cannot be used if [GatewayPayloadFormat.etf] is used.
  payload,
}
