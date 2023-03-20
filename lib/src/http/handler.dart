import 'dart:collection';

import 'package:http/http.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/bucket.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';

/// A handler for making HTTP requests to the Discord API.
///
/// {@template http_handler}
/// HTTP requests can be made using the [execute] method. Rate limiting is anticipated and requests
/// will not be sent if their bucket is out of remaining requests or if the global rate limit was
/// exceeded.
/// {@endtemplate}
class HttpHandler {
  /// The client this handler is attached to.
  final Nyxx client;

  /// The HTTP client used to make requests.
  final Client httpClient = Client();

  final Map<String, HttpBucket> _buckets = {};

  /// A mapping of [HttpRequest.rateLimitId] to [HttpBucket] for rate limiting.
  Map<String, HttpBucket> get buckets => UnmodifiableMapView(_buckets);

  DateTime? _globalReset;

  /// The time at which the global rate limit resets.
  ///
  /// Will be `null` if no global rate limit has been encountered.
  DateTime? get globalReset => _globalReset;

  /// Create a new [HttpHandler].
  ///
  /// {@macro http_handler}
  HttpHandler(this.client);

  /// Send [request] to the API and return the response.
  ///
  /// The request will not be sent immediately if its corresponding bucket is out of remaining
  /// requests or if the global rate limit has been hit. Instead, this method will wait until the
  /// rate limit has passed to send the request.
  ///
  /// If the response has a status code of 2XX, a [HttpResponseSuccess] is returned.
  ///
  /// If the response has a status code of 429, rate limit information is extracted from the
  /// response and the request is sent again after the rate limit passes. The response returned is
  /// that of the second request.
  ///
  /// Otherwise, this method returns a [HttpResponseError].
  Future<HttpResponse> execute(HttpRequest request) async {
    final bucket = _buckets[request.rateLimitId];

    final now = DateTime.now();

    final globalWaitTime = globalReset?.difference(now) ?? Duration.zero;
    final bucketNeedsWait = bucket != null && bucket.remaining <= 0;
    final bucketWaitTime = bucketNeedsWait ? bucket.resetAt.difference(now) : Duration.zero;

    final waitTime = globalWaitTime > bucketWaitTime ? globalWaitTime : bucketWaitTime;

    if (waitTime > Duration.zero) {
      await Future.delayed(waitTime);
    }

    try {
      bucket?.addInflightRequest(request);
      final response = await httpClient.send(request.prepare(client));
      return _handle(request, response);
    } finally {
      bucket?.removeInflightRequest(request);
    }
  }

  /// Execute [request] and throw the response if it is not a [HttpResponseSuccess].
  Future<HttpResponseSuccess> executeSafe(HttpRequest request) async {
    final response = await execute(request);

    if (response is! HttpResponseSuccess) {
      throw response;
    }

    return response;
  }

  void _updateRatelimitBucket(HttpRequest request, BaseResponse response) {
    final bucket = _buckets.values.firstWhereSafe(
      (bucket) => bucket.contains(response),
      orElse: () => HttpBucket.fromResponse(this, response),
    );

    if (bucket == null) {
      return;
    }

    _buckets[request.rateLimitId] = bucket;
  }

  Future<HttpResponse> _handle(HttpRequest request, StreamedResponse response) async {
    _updateRatelimitBucket(request, response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await HttpResponseSuccess.fromResponse(request, response);
    }

    final errorResponse = await HttpResponseError.fromResponse(request, response);

    if (errorResponse.statusCode == 429) {
      final responseBody = errorResponse.jsonBody;
      final retryAfter =
          Duration(milliseconds: ((responseBody["retry_after"] as double) * 1000).ceil());
      final isGlobal = responseBody["global"] as bool;

      if (isGlobal) {
        _globalReset = DateTime.now().add(retryAfter);
      }

      return Future.delayed(retryAfter, () => execute(request));
    }

    return errorResponse;
  }
}
