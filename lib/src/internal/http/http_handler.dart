import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:logging/logging.dart';
import 'package:nyxx/src/events/http_events.dart';
import 'package:nyxx/src/events/ratelimit_event.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/internal/http/http_bucket.dart';
import 'package:nyxx/src/internal/http/http_request.dart';
import 'package:nyxx/src/internal/http/http_response.dart';
import 'package:nyxx/src/utils/utils.dart';

class HttpHandler {
  late final http.Client httpClient;

  final Logger logger = Logger("Http");
  final INyxxRest client;

  RestEventController get _events => client.eventsRest as RestEventController;

  final Map<String, HttpBucket> _bucketByRequestRateLimitId = {};
  DateTime globalRateLimitReset = DateTime.fromMillisecondsSinceEpoch(0);

  /// Creates an instance of [HttpHandler]
  HttpHandler(this.client) {
    httpClient = http.Client();
  }

  HttpBucket? _upsertBucket(HttpRequest request, http.StreamedResponse response) {
    //Get or Create Bucket
    final bucket = _bucketByRequestRateLimitId.values.toList().firstWhereSafe((bucket) => bucket.isInBucket(response)) ?? HttpBucket.fromResponseSafe(response);
    //Update Bucket
    bucket?.updateRateLimit(response);

    //Update request -> bucket mapping
    if (bucket != null) {
      _bucketByRequestRateLimitId.update(
        request.rateLimitId,
        (b) => bucket,
        ifAbsent: () => bucket,
      );
    }

    return bucket;
  }

  Future<HttpResponse> execute(HttpRequest request) async {
    if (request.auth) {
      request.headers.addAll({"Authorization": "Bot ${client.token}"});
    }

    HttpBucket? currentBucket = _bucketByRequestRateLimitId[request.rateLimitId];
    logger.fine(
        "Executing request: [${request.uri.toString()}]; Bucket ID: [${currentBucket?.id}]; Reset at: [${currentBucket?.reset}]; Remaining: [${currentBucket?.remaining}]; Reset after: [${currentBucket?.resetAfter}]; Body: [${request is BasicRequest && request.body != null ? request.body : 'EMPTY'}]");

    // Get actual time and check if request can be executed based on data that bucket already have
    // and wait if rate limit could be possibly hit
    final now = DateTime.now();
    final globalWaitTime = request.globalRateLimit ? globalRateLimitReset.difference(now) : Duration.zero;
    final bucketWaitTime = (currentBucket?.remaining ?? 1) > 0 ? Duration.zero : currentBucket!.reset.difference(now);
    final waitTime = globalWaitTime.compareTo(bucketWaitTime) > 0 ? globalWaitTime : bucketWaitTime;

    if (globalWaitTime > Duration.zero) {
      logger.warning("Global rate limit reached on endpoint: ${request.uri}");
    }

    if (bucketWaitTime > Duration.zero) {
      logger.warning("Bucket rate limit reached on endpoint: ${request.uri}");
    }

    if (waitTime > Duration.zero) {
      logger.warning("Trying to send request again in $waitTime");
      _events.onRateLimitedController.add(RatelimitEvent(request, true));
      return await Future.delayed(waitTime, () async => await execute(request));
    }

    // Execute request
    currentBucket?.addInFlightRequest(request);
    final response = await client.options.httpRetryOptions.retry(
      () async => httpClient.send(await request.prepareRequest()),
      onRetry: (ex) => logger.shout('Exception when sending HTTP request (retrying automatically): $ex'),
    );
    currentBucket?.removeInFlightRequest(request);
    currentBucket = _upsertBucket(request, response);
    return _handle(request, response);
  }

  Future<HttpResponse> _handle(HttpRequest request, http.StreamedResponse response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseSuccess = await HttpResponseSuccess.fromResponse(response);

      (client.eventsRest as RestEventController).onHttpResponseController.add(HttpResponseEvent(responseSuccess));
      logger.finer("Got successful http response for endpoint: [${response.request?.url.toString()}]; Response: [${responseSuccess.jsonBody}]");

      return responseSuccess;
    }

    // Check for 429, emit events and wait given in response body time
    if (response.statusCode == 429) {
      final responseBody = jsonDecode(await response.stream.bytesToString());
      final retryAfter = Duration(milliseconds: ((responseBody["retry_after"] as double) * 1000).ceil());
      final isGlobal = responseBody["global"] as bool;

      if (isGlobal) {
        globalRateLimitReset = DateTime.now().add(retryAfter);
      }

      _events.onRateLimitedController.add(RatelimitEvent(request, false, response));
      logger.warning("${isGlobal ? "Global " : ""}Rate limited via 429 on endpoint: ${request.uri}. Trying to send request again in $retryAfter");

      return Future.delayed(retryAfter, () => execute(request));
    }

    final responseError = await HttpResponseError.fromResponse(response);

    (client.eventsRest as RestEventController).onHttpErrorController.add(HttpErrorEvent(responseError));
    logger.finer("Got failure http response for endpoint: [${response.request?.url.toString()}]; Response: [${responseError.message}]");

    return responseError;
  }
}
