part of nyxx;

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
