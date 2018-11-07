part of nyxx;

/// Sent when the client is ratelimited, either by the ratelimit handler itself,
/// or when a 429 is received.
class RatelimitEvent {
  /// True if ratelimit handler stopped the request
  /// False if the client received a 429
  bool handled;

  /// The request that was ratelimited.
  HttpBase request;

  /// The response received if the ratelimit handler did not stop
  /// the request (rare)
  HttpResponse response;

  RatelimitEvent._new(this.request, this.handled, [this.response]);
}
