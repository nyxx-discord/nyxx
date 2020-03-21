part of nyxx;

/// Sent when the client is ratelimited, either by the ratelimit handler itself,
/// or when a 429 is received.
class RatelimitEvent {
  /// True if ratelimit handler stopped the request
  /// False if the client received a 429
  final bool handled;

  /// The request that was ratelimited.
  final HttpBase request;

  /// The error response received if the ratelimit handler did not stop
  /// the request (aka hit 429)
  final HttpResponse? response;

  RatelimitEvent._new(this.request, this.handled, [this.response]);
}
