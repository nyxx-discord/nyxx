import 'dart:collection';

import 'package:http/http.dart' hide MultipartRequest;
import 'package:logging/logging.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/bucket.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';

extension on HttpRequest {
  String get loggingId => '$method $route';
}

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

  Logger get logger => Logger('${client.options.loggerName}.Http');

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
    logger
      ..fine(request.loggingId)
      ..finer(
        'Rate Limit ID: ${request.rateLimitId}, Headers: ${request.headers}, Audit Log Reason: ${request.auditLogReason},'
        ' Authenticated: ${request.authenticated}, Apply Global Rate Limit: ${request.applyGlobalRateLimit}',
      );

    if (request is BasicRequest) {
      logger.finer('Query Parameters: ${request.queryParameters}, Body: ${request.body}');
    } else if (request is MultipartRequest) {
      logger.finer('Query parameters: ${request.queryParameters}, Payload: ${request.jsonPayload}, Files: ${request.files.map((e) => e.filename).join(', ')}');
    } else {
      logger.finer('Query parameters: ${request.queryParameters}');
    }

    final bucket = _buckets[request.rateLimitId];

    final now = DateTime.now();

    final globalWaitTime = globalReset?.difference(now) ?? Duration.zero;
    final bucketNeedsWait = bucket != null && bucket.remaining <= 0;
    final bucketWaitTime = bucketNeedsWait ? bucket.resetAt.difference(now) : Duration.zero;

    final waitTime = globalWaitTime > bucketWaitTime ? globalWaitTime : bucketWaitTime;

    if (waitTime > Duration.zero) {
      logger.finer('Holding ${request.loggingId} for $waitTime');
      await Future.delayed(waitTime);
    }

    try {
      logger.finer('Sending ${request.loggingId}');

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

    final HttpResponse parsedResponse;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      parsedResponse = await HttpResponseSuccess.fromResponse(request, response);
    } else {
      parsedResponse = await HttpResponseError.fromResponse(request, response);
    }

    logger
      ..fine('${response.statusCode} ${request.loggingId}')
      ..finer('Headers: ${parsedResponse.headers}, Body: ${parsedResponse.textBody ?? parsedResponse.body.map((e) => e.toRadixString(16)).join(' ')}');

    if (parsedResponse.statusCode == 429) {
      try {
        final responseBody = parsedResponse.jsonBody;
        final retryAfter = Duration(milliseconds: ((responseBody["retry_after"] as double) * 1000).ceil());
        final isGlobal = responseBody["global"] as bool;

        if (isGlobal) {
          _globalReset = DateTime.now().add(retryAfter);
        }

        return Future.delayed(retryAfter, () => execute(request));
      } on TypeError {
        logger.shout('Invalid rate limit body for ${request.loggingId}! Your client is probably cloudflare banned!');
      }
    }

    return parsedResponse;
  }
}
