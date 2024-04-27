import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' hide MultipartRequest;
import 'package:logging/logging.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/bucket.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:nyxx/src/plugin/plugin.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';

extension on HttpRequest {
  String get loggingId => '$method $route';
}

/// Information about a [delay] applied to [request] because of a rate limit.
///
/// [isGlobal] indicates if the delay applied is due to the global rate limit.
/// [isAnticipated] will be true if the request was delayed before it was sent. If [isAnticipated] is `false`,
/// a response with the status code 429 was received from the API.
typedef RateLimitInfo = ({HttpRequest request, Duration delay, bool isGlobal, bool isAnticipated});

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

  final StreamController<HttpRequest> _onRequestController = StreamController.broadcast();
  final StreamController<HttpResponse> _onResponseController = StreamController.broadcast();
  final StreamController<RateLimitInfo> _onRateLimitController = StreamController.broadcast();

  /// A stream of requests executed by this handler.
  ///
  /// Requests are emitted before they are sent.
  Stream<HttpRequest> get onRequest => _onRequestController.stream;

  /// A stream of responses received by this handler.
  ///
  /// This includes error & rate limit responses. Since rate limit responses trigger the request
  /// to be retried, this means you may receive multiple responses for a single request on this
  /// stream.
  Stream<HttpResponse> get onResponse => _onResponseController.stream;

  /// A stream that emits an event when a request is delayed because of a rate limit.
  Stream<RateLimitInfo> get onRateLimit => _onRateLimitController.stream;

  final Queue<Duration> _realLatencies = DoubleLinkedQueue();
  final Queue<Duration> _latencies = DoubleLinkedQueue();

  final Expando<Stopwatch> _latencyStopwatches = Expando();

  static const _latencyRequestCount = 10;

  /// The average time taken by the last 10 requests to get a response.
  ///
  /// This time includes the time requests are held or retried due to rate limits. It is an indicator of how long the [Future] returned by [execute] is likely
  /// to take to complete.
  ///
  /// If no requests have been completed, this getter returns [Duration.zero].
  ///
  /// To get the network latency for this [HttpHandler], see [realLatency].
  Duration get latency => _latencies.isEmpty ? Duration.zero : (_latencies.reduce((a, b) => a + b) ~/ _latencies.length);

  /// The average network and API latency of the last 10 requests.
  ///
  /// This time measures how long each request takes to get a response from Discord's API, regardless of holding or retries due to rate limiting. This is not an
  /// indicator of how long each call to [execute] takes to complete.
  ///
  /// If no requests have been completed, this getter returns [Duration.zero].
  Duration get realLatency => _realLatencies.isEmpty ? Duration.zero : (_realLatencies.reduce((a, b) => a + b) ~/ _realLatencies.length);

  /// Create a new [HttpHandler].
  ///
  /// {@macro http_handler}
  HttpHandler(this.client) {
    if (client.options.rateLimitWarningThreshold case final threshold?) {
      onRateLimit.listen((info) {
        final (:request, :delay, :isGlobal, :isAnticipated) = info;
        final requestStopwatch = _latencyStopwatches[request];
        if (requestStopwatch == null) return;

        final totalDelay = requestStopwatch.elapsed + delay;

        // Prevent warnings being emitted too often. This limits warnings to once per [threshold].
        if (totalDelay.inMicroseconds ~/ threshold.inMicroseconds <= requestStopwatch.elapsedMicroseconds ~/ threshold.inMicroseconds) return;

        if (totalDelay > threshold) {
          logger.warning(
            '${request.loggingId} has been pending for ${requestStopwatch.elapsed} and will be sent in $delay due to rate limiting.'
            ' The request will have been pending for $totalDelay.',
          );
          if (isAnticipated) {
            logger.info('This is a predicted rate limit and was anticipated based on previous responses');
          } else if (isGlobal) {
            logger.info('This is a global rate limit and will apply to all requests for the next $delay');
          } else {
            logger.info('This rate limit was returned by the API');
          }
        }
      });
    }
  }

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
  ///
  /// This method calls [NyxxPlugin.interceptRequest] on all plugins registered to the [client] which may intercept the [request].
  Future<HttpResponse> execute(HttpRequest request) async {
    final executeFn = client.options.plugins.fold(
      _execute,
      (previousValue, plugin) => (request) => plugin.interceptRequest(client, request, previousValue),
    );
    return await executeFn(request);
  }

  Future<HttpResponse> _execute(HttpRequest request) async {
    logger
      ..fine(request.loggingId)
      ..finer(
        'Rate Limit ID: ${request.rateLimitId}, Headers: ${request.headers}, Audit Log Reason: ${request.auditLogReason},'
        ' Authenticated: ${request.authenticated}, Apply Global Rate Limit: ${request.applyGlobalRateLimit}',
      );

    if (request is BasicRequest) {
      logger.finer('Query Parameters: ${request.queryParameters}, Body: ${request.body}');
    } else if (request is FormDataRequest) {
      logger.finer('Query parameters: ${request.queryParameters}, Payload: ${request.formParams}, Files: ${request.files.map((e) => e.filename).join(', ')}');
    } else {
      logger.finer('Query parameters: ${request.queryParameters}');
    }

    _onRequestController.add(request);

    // Use ??= instead of = as the request might already exist if it was retried
    // due to a rate limit.
    _latencyStopwatches[request] ??= Stopwatch()..start();

    Duration waitTime;
    HttpBucket? bucket;

    do {
      bucket = _buckets[request.rateLimitId];

      final now = DateTime.now();

      final globalWaitTime = (request.applyGlobalRateLimit ? globalReset?.difference(now) : null) ?? Duration.zero;

      Duration bucketWaitTime = Duration.zero;
      if (bucket != null && bucket.remaining <= 0) {
        if (bucket.resetAt.isAfter(now)) {
          bucketWaitTime = bucket.resetAt.difference(now);
        } else if (bucket.inflightRequests > 0) {
          // This occurs when the bucket has many in flight requests
          // (which take all the remaining request slots) but has not
          // yet received a response to update its reset after time.
          //
          // This would mean the bucket reset time would be negative,
          // when we actually want to wait for an updated reset time.
          //
          // We just wait for one of those requests to complete.
          bucketWaitTime = const Duration(seconds: 1);
        }
      }

      final isGlobal = globalWaitTime > bucketWaitTime && request.applyGlobalRateLimit;
      waitTime = isGlobal ? globalWaitTime : bucketWaitTime;

      if (waitTime > Duration.zero) {
        logger.finer('Holding ${request.loggingId} for $waitTime');
        _onRateLimitController.add((request: request, delay: waitTime, isGlobal: isGlobal, isAnticipated: true));
        await Future.delayed(waitTime);
      }
    } while (waitTime > Duration.zero);

    try {
      logger.finer('Sending ${request.loggingId}');

      final realLatencyStopwatch = Stopwatch()..start();

      bucket?.addInflightRequest(request);
      final response = await httpClient.send(request.prepare(client));

      final realLatency = (realLatencyStopwatch..stop()).elapsed;

      _realLatencies.addLast(realLatency);
      if (_realLatencies.length > _latencyRequestCount) {
        _realLatencies.removeFirst();
      }

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
    HttpBucket? bucket = _buckets.values.firstWhereSafe(
      (bucket) => bucket.contains(response),
      orElse: () => HttpBucket.fromResponse(this, response),
    );

    if (bucket == null) {
      return;
    }

    bucket.updateWith(response);
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

    _onResponseController.add(parsedResponse);

    if (parsedResponse.statusCode == 429) {
      try {
        final responseBody = parsedResponse.jsonBody;
        final retryAfter = Duration(milliseconds: ((responseBody["retry_after"] as double) * 1000).ceil());
        final isGlobal = responseBody["global"] as bool;

        if (isGlobal) {
          _globalReset = DateTime.now().add(retryAfter);
        }

        _onRateLimitController.add((request: request, delay: retryAfter, isGlobal: isGlobal, isAnticipated: false));
        return Future.delayed(retryAfter, () => execute(request));
      } on TypeError {
        logger.shout('Invalid rate limit body for ${request.loggingId}! Your client is probably cloudflare banned!');
      }
    }

    final latency = (_latencyStopwatches[request]?..stop())?.elapsed;
    _latencyStopwatches[request] = null;

    if (latency != null) {
      _latencies.addLast(latency);

      if (_latencies.length > _latencyRequestCount) {
        _latencies.removeFirst();
      }
    }

    return parsedResponse;
  }

  void close() {
    httpClient.close();
    _onRequestController.close();
    _onResponseController.close();
    _onRateLimitController.close();
  }
}

/// An [HttpHandler] that refreshes the OAuth2 access token if needed.
class Oauth2HttpHandler extends HttpHandler {
  /// The options containing the credentials that may be refreshed.
  final OAuth2ApiOptions apiOptions;

  /// Create a new [Oauth2HttpHandler].
  Oauth2HttpHandler(NyxxOAuth2 super.client) : apiOptions = client.apiOptions;

  @override
  Future<HttpResponse> _execute(HttpRequest request) async {
    if (apiOptions.credentials.isExpired && request.authenticated) {
      apiOptions.credentials = await apiOptions.credentials.refresh();
    }

    return await super._execute(request);
  }
}
