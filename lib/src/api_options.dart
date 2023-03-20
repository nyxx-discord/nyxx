/// Options for connecting to the Discord API.
abstract class ApiOptions {
  /// The version of nyxx used in [defaultUserAgent].
  static const nyxxVersion = '6.0.0';

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

  /// Create a new [RestApiOptions].
  RestApiOptions({required this.token, this.userAgent = ApiOptions.defaultUserAgent});
}
