part of nyxx;

class HttpBase {
  StreamController<HttpResponse> _streamController;

  /// The HTTP client.
  Http http;

  /// The bucket the request will go into.
  HttpBucket bucket;

  /// The path the request is being made to.
  String path;

  /// The query params.
  Map<String, String> queryParams;

  /// The final URI that the request is being made to.
  Uri uri;

  /// The HTTP method used.
  String method;

  /// Headers to be sent.
  Map<String, String> headers;

  /// The request body.
  dynamic body;

  /// A stream that sends the response when received. Immediately closed after
  /// a value is sent.
  Stream<HttpResponse> stream;

  HttpBase._new(this.http, this.method, this.path, this.queryParams,
      this.headers, this.body);

  void _finish() {
    this.uri =
        Uri.https(_Constants.host, _Constants.baseUri + path, queryParams);

    if (http.buckets[uri.toString()] == null)
      http.buckets[uri.toString()] = HttpBucket._new(uri.toString());

    this.bucket = http.buckets[uri.toString()];

    this._streamController = StreamController<HttpResponse>.broadcast();
    this.stream = _streamController.stream;

    if (_client != null)
      _client._events.beforeHttpRequestSend
          .add(BeforeHttpRequestSendEvent._new(this));

    if (_client == null || !_client._events.beforeHttpRequestSend.hasListener)
      this.send();
  }

  /// Sends the request off to the bucket to be processed and sent.
  void send() => this.bucket._push(this);

  void abort() {
    this._streamController.add(HttpResponse._aborted(this));
    this._streamController.close();
  }

  Future<HttpResponse> _execute() async {
    var req = transport.JsonRequest()
      ..uri = this.uri
      ..headers = this.headers;

    try {
      if (this.body != null) req.body = this.body;

      if (this.queryParams != null) req.queryParameters = this.queryParams;

      var res = await req.send(this.method);

      return HttpResponse._fromResponse(this, res);
    } on transport.RequestException catch (e) {
      return HttpResponse._fromResponse(this, e.response);
    }
  }
}

class HttpMultipartRequest extends HttpBase {
  Map<String, transport.MultipartFile> files = Map();
  Map<String, dynamic> fields;

  HttpMultipartRequest._new(Http http, String method, String path,
      List<File> files, this.fields, Map<String, String> headers)
      : super._new(http, method, path, null, headers, null) {
    for (var f in files) {
      try {
        var name = Uri.file(f.path).toString().split("/").last;
        this.files[name] = transport.MultipartFile(f.openRead(), f.lengthSync(),
            filename: name);
      } on FileSystemException catch (err) {
        throw Exception("Cannot find your file: ${err.path}");
      }
    }

    super._finish();
  }

  @override
  Future<HttpResponse> _execute() async {
    var req = transport.MultipartRequest()
      ..uri = this.uri
      ..headers = this.headers
      ..files = this.files;

    try {
      if (this.fields != null)
        req.fields.addAll({"payload_json": jsonEncode(this.fields)});

      return HttpResponse._fromResponse(this, await req.send(method));
    } on transport.RequestException catch (e) {
      return HttpResponse._fromResponse(this, e.response);
    }
  }
}

/// A HTTP request.
class HttpRequest extends HttpBase {
  HttpRequest._new(
      Http http,
      String method,
      String path,
      Map<String, String> queryParams,
      Map<String, String> headers,
      dynamic body)
      : super._new(http, method, path, queryParams, headers, body) {
    super._finish();
  }
}

/// A HTTP response. More documentation can be found at the
/// [w_transport docs](https://www.dartdocs.org/documentation/w_transport/3.0.0/w_transport/Response-class.html)
class HttpResponse {
  /// The HTTP request.
  HttpBase request;

  /// Whether or not the request was aborted. If true, all other fields will be null.
  bool aborted;

  /// Status message
  String statusText;

  /// Status code
  int status;

  /// Response headers
  Map<String, String> headers;

  /// Response body
  dynamic body;

  HttpResponse._new(
      this.request, this.status, this.statusText, this.headers, this.body,
      [this.aborted = false]);

  HttpResponse._aborted(this.request, [this.aborted = true]) {
    this.status = 0;
    this.statusText = "ABORTED";
    this.headers = {};
    this.body = {};
  }

  static Future<HttpResponse> _fromResponse(
      HttpBase request, transport.BaseResponse r) async {
    var json;
    try {
      json = (r as transport.Response).body.asJson();
    } on Exception {}

    return HttpResponse._new(request, r.status, "", r.headers, json);
  }

  @override
  String toString() =>
      "STATUS [$status], STATUS TEXT: [$statusText], RESPONSE: [$body]";
}

/// A bucket for managing ratelimits.
class HttpBucket {
  /// The url that this bucket is handling requests for.
  String url;

  /// The number of requests that can be made.
  int limit;

  /// The number of remaining requests that can be made. May not always be accurate.
  int rateLimitRemaining = 2;

  /// When the ratelimits reset.
  DateTime rateLimitReset;

  /// The time difference between you and Discord.
  //Duration timeDifference;

  /// A queue of requests waiting to be sent.
  List<HttpBase> requests = <HttpBase>[];

  /// Whether or not the bucket is waiting for a request to complete
  /// before continuing.
  bool waiting = false;

  HttpBucket._new(this.url);

  void _push(HttpBase request) {
    this.requests.add(request);
    this._handle();
  }

  void _handle() {
    if (this.waiting || this.requests.length == 0) return;
    this.waiting = true;

    this._execute(this.requests[0]);
  }

  void _execute(HttpBase request) {
    if (this.rateLimitRemaining == null || this.rateLimitRemaining > 1) {
      request._execute().then((HttpResponse r) {
        this.limit = r.headers['x-ratelimit-limit'] != null
            ? int.parse(r.headers['x-ratelimit-limit'])
            : null;
        this.rateLimitRemaining = r.headers['x-ratelimit-remaining'] != null
            ? int.parse(r.headers['x-ratelimit-remaining'])
            : null;
        this.rateLimitReset = r.headers['x-ratelimit-reset'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(r.headers['x-ratelimit-reset']) * 1000,
                isUtc: true)
            : null;

        if (r.status == 429) {
          client._events.onRatelimited
              .add(RatelimitEvent._new(request, false, r));
          request.http._logger.warning(
              "Rate limitted via 429 on endpoint: ${request.path}. Trying to send request again after timeout...");
          Timer(Duration(milliseconds: (r.body['retry_after'] as int) + 100),
              () => this._execute(request));
        } else {
          this.waiting = false;
          this.requests.remove(request);
          request._streamController.add(r);
          request._streamController.close();
          this._handle();
        }
      });
    } else {
      final Duration waitTime =
          this.rateLimitReset.difference(DateTime.now().toUtc()) +
              Duration(milliseconds: 250);
      if (waitTime.isNegative) {
        this.rateLimitRemaining = 2;
        this._execute(request);
      } else {
        client._events.onRatelimited
            .add(RatelimitEvent._new(request as HttpRequest, true));
        request.http._logger.warning(
            "Rate limitted internally on endpoint: ${request.path}. Trying to send request again after timeout...");
        Timer(waitTime, () {
          this.rateLimitRemaining = 2;
          this._execute(request);
        });
      }
    }
  }
}

/// The client's HTTP client.
class Http {
  /// The buckets.
  Map<String, HttpBucket> buckets = Map();

  /// Headers sent on every request.
  Map<String, String> _headers;

  Logger _logger = Logger.detached("Http");

  Http._new() {
    this._headers = {
      'User-Agent':
          'DiscordBot (https://github.com/l7ssha/nyxx, ${_Constants.version})'
    };
  }

  /// Sends a HTTP request.
  Future<HttpResponse> send(String method, String path,
      {dynamic body,
      Map<String, String> queryParams,
      bool beforeReady = false,
      Map<String, String> headers = const {},
      String reason}) async {
    HttpRequest request = HttpRequest._new(
        this,
        method,
        path,
        queryParams,
        Map.from(this._headers)
          ..addAll(headers)
          ..addAll(_addAuditReason(reason)),
        body);

    await for (HttpResponse r in request.stream) {
      if (!r.aborted && r.status >= 200 && r.status < 300) {
        if (_client != null)
          client._events.onHttpResponse.add(HttpResponseEvent._new(r));
        return r;
      } else {
        if (_client != null)
          _client._events.onHttpError.add(HttpErrorEvent._new(r));
        return Future.error(r);
      }
    }

    return Future.error(Exception("Didn't got any response"));
  }

  /// Adds AUDIT_LOG header to request
  Map<String, String> _addAuditReason(String reason) =>
      <String, String>{"X-Audit-Log-Reason": "${reason == null ? "" : reason}"};

  /// Sends multipart request
  Future<HttpResponse> sendMultipart(
      String method, String path, List<File> files,
      {Map<String, dynamic> data,
      bool beforeReady = false,
      String reason}) async {
    if (_client is Nyxx && !_client.ready && !beforeReady)
      return Future.error(Exception("Client isn't ready yet."));

    HttpMultipartRequest request = HttpMultipartRequest._new(this, method, path,
        files, data, Map.from(this._headers)..addAll(_headers));

    if (reason != "" || reason != null)
      request.headers.addAll(_addAuditReason(reason));

    await for (HttpResponse r in request.stream) {
      if (!r.aborted && r.status >= 200 && r.status < 300) {
        if (_client != null)
          client._events.onHttpResponse.add(HttpResponseEvent._new(r));
        return r;
      } else {
        if (_client != null)
          _client._events.onHttpError.add(HttpErrorEvent._new(r));
        return Future.error(r);
      }
    }

    return Future.error(Exception("Didn't got any response"));
  }
}
