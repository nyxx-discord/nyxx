part of nyxx_lavalink;

class HttpException implements Exception {
  /// The status code of the request
  final int code;

  HttpException._new(this.code): super();

  @override
  String toString() =>
      "Lavalink server responded with $code code";
}