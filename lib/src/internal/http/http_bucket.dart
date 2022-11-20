import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:nyxx/src/internal/http/http_request.dart';

class HttpBucket {
  static const String xRateLimitBucket = "x-ratelimit-bucket";
  static const String xRateLimitLimit = "x-ratelimit-limit";
  static const String xRateLimitRemaining = "x-ratelimit-remaining";
  static const String xRateLimitReset = "x-ratelimit-reset";
  static const String xRateLimitResetAfter = "x-ratelimit-reset-after";

  int _remaining;
  DateTime _reset;
  Duration _resetAfter;
  final String _bucketId;

  final List<HttpRequest> _inFlightRequests = [];

  int get remaining => _remaining - _inFlightRequests.length;

  DateTime get reset => _reset;

  Duration get resetAfter => _resetAfter;

  String get id => _bucketId;

  late final Logger _logger = Logger('HttpBucket $id');

  HttpBucket(this._remaining, this._reset, this._resetAfter, this._bucketId);

  static HttpBucket? fromResponseSafe(http.StreamedResponse response) {
    final limit = getLimitFromHeaders(response.headers);
    final remaining = getRemainingFromHeaders(response.headers);
    final reset = getResetFromHeaders(response.headers);
    final resetAfter = getResetAfterFromHeaders(response.headers);
    final bucketId = getBucketIdFromHeaders(response.headers);

    if (limit == null || remaining == null || reset == null || resetAfter == null || bucketId == null) {
      return null;
    }

    return HttpBucket(remaining, reset, resetAfter, bucketId);
  }

  static String? getBucketIdFromHeaders(Map<String, String> headers) => headers[xRateLimitBucket];

  static int? getLimitFromHeaders(Map<String, String> headers) => headers[xRateLimitLimit] == null ? null : int.parse(headers[xRateLimitLimit]!);

  static int? getRemainingFromHeaders(Map<String, String> headers) => headers[xRateLimitRemaining] == null ? null : int.parse(headers[xRateLimitRemaining]!);

  // Server-Client clock drift makes headers.reset useless, build reset from headers.resetAfter and DateTime.now()
  static DateTime? getResetFromHeaders(Map<String, String> headers) =>
      headers[xRateLimitResetAfter] == null ? null : DateTime.now().add(getResetAfterFromHeaders(headers)!);

  static Duration? getResetAfterFromHeaders(Map<String, String> headers) =>
      headers[xRateLimitResetAfter] == null ? null : Duration(milliseconds: (double.parse(headers[xRateLimitResetAfter]!) * 1000).ceil());

  void addInFlightRequest(HttpRequest httpRequest) => _inFlightRequests.add(httpRequest);

  void removeInFlightRequest(HttpRequest httpRequest) => _inFlightRequests.remove(httpRequest);

  bool isInBucket(http.StreamedResponse response) {
    return getBucketIdFromHeaders(response.headers) == _bucketId;
  }

  void updateRateLimit(http.StreamedResponse response) {
    if (isInBucket(response)) {
      _logger.finest('Updating bucket');

      _remaining = getRemainingFromHeaders(response.headers) ?? _remaining;

      _reset = getResetFromHeaders(response.headers) ?? _reset;

      _resetAfter = getResetAfterFromHeaders(response.headers) ?? _resetAfter;

      _logger.finest([
        'Remaining: $_remaining',
        'Reset at: $_reset',
        'Reset after: $_resetAfter',
      ].join('\n'));
    }
  }
}
