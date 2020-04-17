part of nyxx;

class HttpHandler {
  List<_HttpBucket> buckets = [];

  Nyxx client;
  Logger logger = Logger.detached("Http");

  HttpHandler._new(this.client);

  Future<HttpResponse> _execute(HttpRequest request) async {
    request._client = this.client;

    _HttpBucket? bucket = buckets.firstWhere((element) => element.uri == request.uri, orElse: () => null);
    if(bucket == null) {
      var newBucket = _HttpBucket(request.uri, this);
      buckets.add(newBucket);

      return _handle(await newBucket._execute(request));
    }

    return _handle(await bucket._execute(request));
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
  int? max;
  int remaining = 10;
  DateTime? resetAt;
  int? resetAfter;

  late final Uri uri;

  HttpHandler handler;

  _HttpBucket(this.uri, this.handler);

  Future<transport.Response> _execute(HttpRequest request) async {
    var now = DateTime.now();

    if(resetAt != null && resetAt!.isAfter(now) && remaining < 2) {
      var waitTime = resetAt!.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

      handler.client._events.onRatelimited.add(RatelimitEvent._new(request, true));
      handler.logger.warning("Rate limitted internally on endpoint: ${request.uri}. Trying to send request again in $waitTime ms...");

      return Future.delayed(Duration(milliseconds: waitTime), () => _execute(request));
    }

    try {
      var response = await request._execute();

      _setBucketValues(response.headers);
      return response;
    } on transport.RequestException catch (e) {
      var response = e.response as transport.Response;

      if(response.status == 429) {
        var retryAfter = response.body.asJson()['retry_after'] as int;

        handler.client._events.onRatelimited.add(RatelimitEvent._new(request, false, response));
        handler.logger.warning("Rate limitted via 429 on endpoint: ${request.uri}. Trying to send request again in $retryAfter ms...");

        return Future.delayed(Duration(milliseconds: retryAfter), () => _execute(request));
      }

      _setBucketValues(response.headers);
      return response;
    }
  }

  void _setBucketValues(Map<String, String> headers) {
    if(headers["x-ratelimit-remaining"] != null) {
      this.remaining = int.parse(headers["x-ratelimit-remaining"]);
    }

    if(headers["x-ratelimit-reset"] != null) {
      this.resetAt = DateTime.fromMillisecondsSinceEpoch(int.parse(headers["x-ratelimit-reset"]));
    }

    if(headers["x-ratelimit-reset-after"] != null) {
      this.resetAfter = int.parse(headers["x-ratelimit-reset-after"]);
    }
  }

}