import 'package:http/http.dart' as http;

import 'package:nyxx/src/internal/http/http_request.dart';

abstract class IRatelimitEvent {
  /// True if rate limit handler stopped the request
  /// False if the client received a 429
  bool get handled;

  /// The request that was rate limited.
  HttpRequest get request;

  /// The error response received if the rate limit handler did not stop
  /// the request (aka hit 429)
  http.BaseResponse? get response;
}

/// Sent when the client is rate limit
/// ed, either by the rate limit handler itself,
/// or when a 429 is received.
class RatelimitEvent implements IRatelimitEvent {
  /// True if rate limit handler stopped the request
  /// False if the client received a 429
  @override
  final bool handled;

  /// The request that was rate limited.
  @override
  final HttpRequest request;

  /// The error response received if the rate limit handler did not stop
  /// the request (aka hit 429)
  @override
  final http.BaseResponse? response;

  /// Creates an instance of [RatelimitEvent]
  RatelimitEvent(this.request, this.handled, [this.response]);
}
