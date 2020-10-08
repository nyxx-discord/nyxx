part of nyxx;

class _HttpClient extends http.BaseClient {
  late final Map<String, String> _authHeader;

  final http.Client _innerClient = http.Client();

  // ignore: public_member_api_docs
  _HttpClient(Nyxx client) {
    this._authHeader = {
     "Authorization" : "Bot ${client._token}"
    };
  }
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(this._authHeader);
    final response = await this._innerClient.send(request);

    if (response.statusCode >= 400) {
      throw HttpClientException(response);
    }

    return response;
  }
}

class HttpClientException extends http.ClientException {
  /// Raw response from server
  final http.BaseResponse? response;

  // ignore: public_member_api_docs
  HttpClientException(this.response) : super("Exception", response?.request?.url);
}

class _HttpHandler {
  final List<_HttpBucket> _buckets = [];
  late final _HttpBucket _noRateBucket;

  final Logger _logger = Logger("Http");
  late final _HttpClient _httpClient;
  final Nyxx client;

  _HttpHandler._new(this.client) {
    this._noRateBucket = _HttpBucket(Uri.parse("noratelimit"), this);
    this._httpClient = _HttpClient(client);
  }

  Future<_HttpResponse> _execute(_HttpRequest request) async {
    request._client = this._httpClient;

    if (!request.rateLimit) {
      return _handle(await this._noRateBucket._execute(request));
    }

    // TODO: NNBD: try-catch in where
    try {
      final bucket = _buckets.firstWhere((element) => element.uri == request.uri);

      return _handle(await bucket._execute(request));
    } on Error {
      final newBucket = _HttpBucket(request.uri, this);
      _buckets.add(newBucket);

      return _handle(await newBucket._execute(request));
    }
  }

  Future<_HttpResponse> _handle(http.StreamedResponse response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseSuccess = HttpResponseSuccess._new(response);
      await responseSuccess._finalize();

      client._events.onHttpResponse.add(HttpResponseEvent._new(responseSuccess));
      return responseSuccess;
    }

    final responseError = HttpResponseError._new(response);
    await responseError._finalize();

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
  final _HttpHandler _httpHandler;

  _HttpBucket(this.uri, this._httpHandler);

  Future<http.StreamedResponse> _execute(_HttpRequest request) async {
    // Get actual time and check if request can be executed based on data that bucket already have
    // and wait if rate limit could be possibly hit
    final now = DateTime.now();
    if ((resetAt != null && resetAt!.isAfter(now)) && remaining < 2) {
      final waitTime = resetAt!.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

      if (waitTime > 0) {
        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, true));
        _httpHandler._logger.warning(
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
        return Future.delayed(const Duration(milliseconds: 1000), () => _execute(request));
      }

      final response = e.response as http.StreamedResponse;

      // Check for 429, emmit events and wait given in response body time
      if (response.statusCode == 429) {
        final responseBody = jsonDecode(await response.stream.bytesToString());
        final retryAfter = responseBody["retry_after"] as int;

        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, false, response));
        _httpHandler._logger.warning(
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
      final secondsSinceEpoch = int.parse(headers["x-ratelimit-reset"]!) * 1000;
      this.resetAt = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch);
    }

    if (headers["x-ratelimit-reset-after"] != null) {
      this.resetAfter = int.parse(headers["x-ratelimit-reset-after"]!);
    }
  }
}
