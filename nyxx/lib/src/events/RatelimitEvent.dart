part of nyxx;

/// Sent when the client is rate limit
/// ed, either by the rate limit handler itself,
/// or when a 429 is received.
class RatelimitEvent {
  /// True if rate limit handler stopped the request
  /// False if the client received a 429
  final bool handled;

  /// The request that was rate limited.
  final HttpRequest request;

  /// The error response received if the rate limit handler did not stop
  /// the request (aka hit 429)
  final transport.Response? response;

  RatelimitEvent._new(this.request, this.handled, [this.response]);
}
