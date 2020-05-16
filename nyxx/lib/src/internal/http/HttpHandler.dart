part of nyxx;

class _HttpHandler {
  List<_HttpBucket> _buckets = [];
  late final _HttpBucket _noRateBucket;

  Logger _logger = Logger("Http");
  Nyxx client;

  _HttpHandler._new(this.client) {
    this._noRateBucket = _HttpBucket(Uri.parse("noratelimit"), this);
  }

  Future<HttpResponse> _execute(HttpRequest request) async {
    request._client = this.client;

    if(!request.ratelimit) {
      return _handle(await this._noRateBucket._execute(request));
    }

    // TODO: NNBD: try-catch in where
    try {
      _HttpBucket bucket = _buckets.firstWhere((element) => element.uri == request.uri);

      return _handle(await bucket._execute(request));
    } catch (e) {
      var newBucket = _HttpBucket(request.uri, this);
      _buckets.add(newBucket);

      return _handle(await newBucket._execute(request));
    }
  }

  Future<HttpResponse> _handle(transport.Response response) async {
    if(response.status >= 200 && response.status < 300) {
      var responseSuccess = HttpResponseSuccess._new(response);

      client._events.onHttpResponse.add(HttpResponseEvent._new(responseSuccess));
      return responseSuccess;
    }

    var responseError = HttpResponseError._new(response);
    client._events.onHttpError.add(HttpErrorEvent._new(responseError));
    return responseError;
  }
}

class _HttpBucket {
  // Rate limits
  int remaining = 10;
  DateTime? resetAt;
  int? resetAfter;

  // Bucket uri
  late final Uri uri;

  // Reference to http handler
  _HttpHandler _httpHandler;

  _HttpBucket(this.uri, this._httpHandler);

  Future<transport.Response> _execute(HttpRequest request) async {
    // Get acutual time and check if request can be executed based on data that bucket already have
    // and wait if ratelimit could be possibly hit
    var now = DateTime.now();
    if((resetAt != null && resetAt!.isAfter(now)) && remaining < 2) {
      var waitTime = resetAt!.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

      if(waitTime > 0) {
        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, true));
        _httpHandler._logger.warning("Rate limitted internally on endpoint: ${request.uri}. Trying to send request again in $waitTime ms...");

        return Future.delayed(Duration(milliseconds: waitTime), () => _execute(request));
      }
    }

    // Execute request
    try {
      var response = await request._execute();

      _setBucketValues(response.headers);
      return response;
    } on transport.RequestException catch (e) {
      if(e.response == null) {
        _httpHandler._logger.warning("Http Error on endpoint: ${request.uri}. Error: [${e.error.toString()}].");
        return Future.delayed(Duration(milliseconds: 1000), () => _execute(request));
      }

      var response = e.response as transport.Response;

      // Check for 429, emmit events and wait given in response body time
      if(response.status == 429) {
        var retryAfter = response.body.asJson()['retry_after'] as int;

        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, false, response));
        _httpHandler._logger.warning("Rate limitted via 429 on endpoint: ${request.uri}. Trying to send request again in $retryAfter ms...");

        return Future.delayed(Duration(milliseconds: retryAfter), () => _execute(request));
      }

      // Return http error
      _setBucketValues(response.headers);
      return response;
    }
  }

  void _setBucketValues(Map<String, String> headers) {
    if(headers["x-ratelimit-remaining"] != null) {
      this.remaining = int.parse(headers["x-ratelimit-remaining"]!);
    }

    // seconds since epoch
    if(headers["x-ratelimit-reset"] != null) {
      var secondsSinceEpoch = (int.parse(headers["x-ratelimit-reset"]!) * 1000);
      this.resetAt = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch);
    }

    if(headers['x-ratelimit-reset-after'] != null) {
      this.resetAfter = int.parse(headers['x-ratelimit-reset-after']!);
    }
  }

}