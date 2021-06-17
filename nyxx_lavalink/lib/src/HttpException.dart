part of nyxx_lavalink;

/// An exception that can be thrown when using
/// [Node.searchTracks] or [Node.autoSearch] if the request fails
class HttpException implements Exception {
  /// The status code of the request
  final int code;

  HttpException._new(this.code): super();

  @override
  String toString() =>
      "Lavalink server responded with $code code";
}
