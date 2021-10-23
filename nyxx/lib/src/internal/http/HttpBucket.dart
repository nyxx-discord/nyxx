part of nyxx;

class _HttpBucket {
  // Rate limits
  int remaining = 10;
  DateTime? resetAt;
  double? resetAfter;

  // Bucket ID
  late final String id;

  // Reference to http handler
  final _HttpHandler _httpHandler;

  _HttpBucket(this.id, this._httpHandler);

  Future<http.StreamedResponse> _execute(_HttpRequest request) async {
    this._httpHandler._logger.fine("Executing request: [${request.uri.toString()}]; Bucket ID: [$id]; Reset at: [$resetAt]; Remaining: [$remaining]; Reset after: [$resetAfter]");

    // Get actual time and check if request can be executed based on data that bucket already have
    // and wait if rate limit could be possibly hit
    final now = DateTime.now();
    if ((resetAt != null && resetAt!.isAfter(now)) && remaining < 2) {
      final waitTime = resetAt!.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

      if (waitTime > 0) {
        _httpHandler.client.eventsRest.onRateLimitedController.add(RatelimitEvent(request, true));
        _httpHandler.logger.warning(
            "Rate limited internally on endpoint: ${request.uri}. Trying to send request again in $waitTime ms...");

        return Future.delayed(Duration(milliseconds: waitTime), () => _execute(request));
      }
    }

    // Execute request
    try {
      final response = await request._execute();

      _setBucketValues(response.headers);
      return response;
    } on HttpClientException catch (e) {
      if (e.response == null) {
        _httpHandler._logger.warning("Http Error on endpoint: ${request.uri}. Error: [${e.message.toString()}].");
        return Future.error(e);
      }

      final response = e.response as http.StreamedResponse;

      // Check for 429, emmit events and wait given in response body time
      if (response.statusCode == 429) {
        final responseBody = jsonDecode(await response.stream.bytesToString());
        final retryAfter = ((responseBody["retry_after"] as double) * 1000).round();

        _httpHandler.client.eventsRest.onRateLimitedController.add(RatelimitEvent(request, false, response));
        _httpHandler.logger.warning(
            "Rate limited via 429 on endpoint: ${request.uri}. Trying to send request again in $retryAfter ms...");

        return Future.delayed(Duration(milliseconds: retryAfter), () => _execute(request));
      }

      // Return http error
      _setBucketValues(response.headers);
      return response;
    }
  }

  void _setBucketValues(Map<String, String> headers) {
    if (headers["x-ratelimit-remaining"] != null) {
      this.remaining = int.parse(headers["x-ratelimit-remaining"]!);
    }

    // seconds since epoch
    if (headers["x-ratelimit-reset"] != null) {
      final secondsSinceEpoch = (double.parse(headers["x-ratelimit-reset"]!) * 1000000).toInt();
      this.resetAt = DateTime.fromMicrosecondsSinceEpoch(secondsSinceEpoch);
    }

    if (headers["x-ratelimit-reset-after"] != null) {
      this.resetAfter = double.parse(headers["x-ratelimit-reset-after"]!);
    }

    this._httpHandler._logger.finer("Added http header values: HTTP Bucket ID: [${headers['x-ratelimit-bucket']}]; Reset at: [$resetAt]; Remaining: [$remaining]; Reset after: [$resetAfter]");
  }
}
