import 'package:http/http.dart';
import 'package:nyxx/src/http/handler.dart';
import 'package:nyxx/src/http/request.dart';

/// A rate limit bucket tracking requests.
///
/// {@template http_bucket}
/// Every response from Discord's API contains headers to handle rate limiting. This class keeps
/// track of these headers in a single rate limit bucket (identified by the [xRateLimitBucket]
/// header) and allows the client to anticipate rate limits.
///
/// Every [HttpHandler] stores a map of [HttpRoute.rateLimitId] to [HttpBucket] and implicitly
/// checks each request before sending it, waiting if a rate limit would be exceeded.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/rate-limits#rate-limits
/// {@endtemplate}
class HttpBucket {
  /// The name of the header containing the rate limit bucket id.
  static const xRateLimitBucket = "x-ratelimit-bucket";

  /// The name of the header containing the rate limit per reset.
  static const xRateLimitLimit = "x-ratelimit-limit";

  /// The name of the header containing the remaining request count in the current reset.
  static const xRateLimitRemaining = "x-ratelimit-remaining";

  /// The name of the header containing the time at which the rate limit for this bucket will reset.
  ///
  /// This is not used due to issues with server-client clock drift. Instead, [xRateLimitResetAfter]
  /// is used in combination with [DateTime.now] to determine [resetAt].
  static const xRateLimitReset = "x-ratelimit-reset";

  /// The name of the header containing the amount of time until the rate limit resets, in seconds.
  ///
  /// The value of this header can be a floating-point number.
  static const xRateLimitResetAfter = "x-ratelimit-reset-after";

  /// The [HttpHandler] to which this bucket belongs.
  final HttpHandler handler;

  /// The id of this bucket.
  ///
  /// This is the value of the [xRateLimitBucket] header on requests in this bucket.
  final String id;

  final Set<HttpRequest> _inflightRequests = {};

  /// The number of in-flight requests in this bucket.
  ///
  /// {@macro in_flight_requests}
  int get inflightRequests => _inflightRequests.length;

  int _remaining;

  /// The remaining number of requests that can be made in this reset period.
  ///
  /// This value accounts for in-flight requests, see [addInflightRequest] and
  /// [removeInflightRequest] for more information.
  int get remaining => _remaining - inflightRequests;

  DateTime _resetAt;

  /// The time at which this bucket resets.
  DateTime get resetAt => _resetAt;

  /// The duration after which this bucket resets.
  Duration get resetAfter => resetAt.difference(DateTime.now());

  /// Create a new [HttpBucket].
  ///
  /// {@macro http_bucket}
  HttpBucket(
    this.handler, {
    required this.id,
    required int remaining,
    required DateTime resetAt,
  })  : _remaining = remaining,
        _resetAt = resetAt;

  /// Create a [HttpBucket] from a response from the API.
  ///
  /// If the [response] does not have rate limit headers, this method returns `null`.
  ///
  /// {@macro http_bucket}
  static HttpBucket? fromResponse(HttpHandler handler, BaseResponse response) {
    final limit = response.headers[xRateLimitLimit];
    final remaining = response.headers[xRateLimitRemaining];
    final resetAfter = response.headers[xRateLimitResetAfter];
    final id = response.headers[xRateLimitBucket];

    if (limit == null || remaining == null || resetAfter == null || id == null) {
      return null;
    }

    final resetAfterDuration = Duration(milliseconds: (double.parse(resetAfter) * 1000).ceil());
    final resetAtTime = DateTime.now().add(resetAfterDuration);

    return HttpBucket(
      handler,
      id: id,
      remaining: int.parse(remaining),
      resetAt: resetAtTime,
    );
  }

  /// Update this bucket with the values from [response].
  ///
  /// Call this method for every response in this bucket.
  void updateWith(BaseResponse response) {
    assert(contains(response), 'Response was not in bucket');

    final remaining = response.headers[xRateLimitRemaining];
    final resetAfter = response.headers[xRateLimitResetAfter];

    if (remaining != null) {
      _remaining = int.parse(remaining);
    }

    if (resetAfter != null) {
      final resetAfterDuration = Duration(milliseconds: (double.parse(resetAfter) * 1000).ceil());
      _resetAt = DateTime.now().add(resetAfterDuration);
    }
  }

  /// Return whether the [response]'s [xRateLimitBucket] header matches this bucket's.
  bool contains(BaseResponse response) => id == response.headers[xRateLimitBucket];

  /// Add [request] to this bucket's in-flight requests.
  ///
  /// {@template in_flight_requests}
  /// In flight requests are requests that have been sent by the client but have not yet received a
  /// response from the API. These requests count towards the [remaining] count to avoid sending too
  /// many requests at once.
  /// {@endtemplate}
  void addInflightRequest(HttpRequest request) => _inflightRequests.add(request);

  /// Remove [request] from this bucket's in-flight requests.
  ///
  /// {@macro in_flight_requests}
  void removeInflightRequest(HttpRequest request) => _inflightRequests.remove(request);
}
