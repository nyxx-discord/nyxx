part of nyxx;

class _HttpHandler {
  final RegExp _bucketRegexp = RegExp(r"\/(channels|guilds)\/(\d+)");
  final RegExp _bucketReactionsRegexp =
      RegExp(r"\/channels/(\d+)\/messages\/(\d+)\/reactions");
  final RegExp _bucketCommandPermissions =
      RegExp(r"\/applications/(\d+)\/guilds\/(\d+)\/commands/permissions");

  final List<_HttpBucket> _buckets = [];
  late final _HttpBucket _noRateBucket;

  final Logger _logger = Logger("Http");
  late final _HttpClient _httpClient;

  final INyxx _client;

  _HttpHandler._new(this._client) {
    this._noRateBucket = _HttpBucket("", this);
    this._httpClient = _HttpClient(_client);
  }

  Future<_HttpResponse> _execute(_HttpRequest request) async {
    request._client = this._httpClient;

    if (!request.rateLimit) {
      return _handle(await this._noRateBucket._execute(request));
    }

    final bucket = this._getBucketForRequest(request);
    return _handle(await bucket._execute(request));
  }

  _HttpBucket _getBucketForRequest(_HttpRequest request) {
    final reactionsRegexMatch =
        _bucketReactionsRegexp.firstMatch(request.uri.toString());
    if (reactionsRegexMatch != null) {
      final bucketMajorId = reactionsRegexMatch.group(1);
      final bucketMessageId = reactionsRegexMatch.group(2);

      return this._findBucketById("reactions/$bucketMajorId/$bucketMessageId");
    }

    final commandPermissionRegexMatch =
        _bucketCommandPermissions.firstMatch(request.uri.toString());

    if (commandPermissionRegexMatch != null) {
      final bucketMajorId = commandPermissionRegexMatch.group(1);
      final bucketMessageId = commandPermissionRegexMatch.group(2);

      return this._findBucketById("commands/permissions/$bucketMajorId/$bucketMessageId");
    }

    final bucketRegexMatch = _bucketRegexp.firstMatch(request.uri.toString());
    late String bucketId;

    if (bucketRegexMatch == null) {
      bucketId = request.uri.toString();
    } else {
      final bucketName = bucketRegexMatch.group(1);
      final bucketMajorId = bucketRegexMatch.group(2);
      bucketId = "${request.method}/$bucketName/$bucketMajorId";
    }

    return this._findBucketById(bucketId);
  }

  _HttpBucket _findBucketById(String bucketId) {
    try {
      return _buckets.firstWhere((element) => element.id == bucketId);
    } on StateError {
      final newBucket = _HttpBucket(bucketId, this);
      _buckets.add(newBucket);

      return newBucket;
    }
  }

  Future<_HttpResponse> _handle(http.StreamedResponse response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseSuccess = HttpResponseSuccess._new(response);
      await responseSuccess._finalize();

      _client._onHttpResponse.add(HttpResponseEvent._new(responseSuccess));
      return responseSuccess;
    }

    final responseError = HttpResponseError._new(response);
    await responseError._finalize();

    _client._onHttpError.add(HttpErrorEvent._new(responseError));
    return responseError;
  }
}
