import 'package:http/http.dart' as http;

import 'package:nyxx/src/internal/http/http_request.dart';

class HttpBucket {
  static const String xRateLimitBucket = "x-ratelimit-bucket";
  static const String kRateLimitLimit = "x-ratelimit-limit";
  static const String kRateLimitRemaining = "x-ratelimit-remaining";
  static const String kRateLimitReset = "x-ratelimit-reset";
  static const String kRateLimitResetAfter = "x-ratelimit-reset-after";

  int _limit;
  int _remaining;
  DateTime _reset;
  Duration _resetAfter;
  final String _bucketId;

  final List<HttpRequest> _inFlightRequests = [];

  int get remaining => _remaining - _inFlightRequests.length;

  DateTime get reset => _reset;

  Duration get resetAfter => _resetAfter;

  String get id => _bucketId;

  HttpBucket(this._limit, this._remaining, this._reset, this._resetAfter, this._bucketId);

  static HttpBucket? fromResponseSafe(http.StreamedResponse response) {
    int? limit = getLimitFromHeaders(response.headers);
    int? remaining = getRemainingFromHeaders(response.headers);
    DateTime? reset = getResetFromHeaders(response.headers);
    Duration? resetAfter = getResetAfterFromHeaders(response.headers);
    String? bucketId = getBucketIdFromHeaders(response.headers);

    if (limit == null || remaining == null || reset == null || resetAfter == null || bucketId == null) {
      return null;
    }

    return HttpBucket(limit, remaining, reset, resetAfter, bucketId);
  }

  static String? getBucketIdFromHeaders(Map<String, String> headers) => headers[xRateLimitBucket];

  static int? getLimitFromHeaders(Map<String, String> headers) => headers[kRateLimitLimit] == null ? null : int.parse(headers[kRateLimitLimit]!);

  static int? getRemainingFromHeaders(Map<String, String> headers) => headers[kRateLimitRemaining] == null ? null : int.parse(headers[kRateLimitRemaining]!);

  // Server-Client clock drift makes headers.reset useless, build reset from headers.resetAfter and DateTime.now()
  static DateTime? getResetFromHeaders(Map<String, String> headers) =>
      headers[kRateLimitResetAfter] == null ? null : DateTime.now().add(getResetAfterFromHeaders(headers)!);

  static Duration? getResetAfterFromHeaders(Map<String, String> headers) =>
      headers[kRateLimitResetAfter] == null ? null : Duration(milliseconds: (double.parse(headers[kRateLimitResetAfter]!) * 1000).ceil());

  void addInFlightRequest(HttpRequest httpRequest) => _inFlightRequests.add(httpRequest);

  void removeInFlightRequest(HttpRequest httpRequest) => _inFlightRequests.remove(httpRequest);

  bool isInBucket(http.StreamedResponse response) {
    return getBucketIdFromHeaders(response.headers) == _bucketId;
  }

  updateRateLimit(http.StreamedResponse response) {
    if (isInBucket(response)) {
      _remaining = getRemainingFromHeaders(response.headers) ?? _remaining;

      _reset = getResetFromHeaders(response.headers) ?? _reset;

      _resetAfter = getResetAfterFromHeaders(response.headers) ?? _resetAfter;
    }
  }
}
