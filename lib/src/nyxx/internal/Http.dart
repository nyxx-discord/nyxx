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

  void finish() {
    this.uri =
        new Uri.https(_Constants.host, _Constants.baseUri + path, queryParams);

    if (http.buckets[uri.toString()] == null)
      http.buckets[uri.toString()] = new HttpBucket._new(uri.toString());

    this.bucket = http.buckets[uri.toString()];

    this._streamController = new StreamController<HttpResponse>.broadcast();
    this.stream = _streamController.stream;

    new BeforeHttpRequestSendEvent._new(this.http._client, this as HttpRequest);

    if (this.http._client == null ||
        !this.http._client._events.beforeHttpRequestSend.hasListener)
      this.send();
  }

  /// Sends the request off to the bucket to be processed and sent.
  void send() => this.bucket._push(this as HttpRequest);

  /// Destroys the request.
  void abort() {
    this._streamController.add(new HttpResponse._aborted(this));
    this._streamController.close();
  }

  Future<HttpResponse> _execute() async {
    print(headers);
    print(uri.toString());
    
    try {
      HttpClientRequest r = await new HttpClient().openUrl(method, uri);
      r.headers.contentType = new ContentType("application", "json", charset: "utf-8");
      if (this.body != null) {
        this.headers.forEach((k, v) => r..headers.add(k, v));
        r..write(jsonEncode(this.body));

        return HttpResponse._fromResponse(this,
            await r.close());
      } else {
        return HttpResponse._fromResponse(
            this,
            await r.close());
      }
    } on Exception {
      return HttpResponse._fromResponse(
          this, null);
    }
  }
}

class HttpMultipartRequest extends HttpBase {
  List<Stream<List<int>>> files = new List();
  Map<String, String> fields;
  List<String> filepaths;
  List<String> filenames;

  HttpMultipartRequest._new(Http http, String method, String path,
      this.filenames, this.filepaths, this.fields, Map<String, String> headers)
      : super._new(http, method, path, null, headers, null) {
    new Map.fromIterables(filenames, filepaths).forEach((name, path) {
      var f = new File(path);
      var contents = f.openRead();

      files.add(contents);
    });

    super.finish();
  }

  @override
  Future<HttpResponse> _execute() async {
    print(uri.toString());
    print(this.headers);

    try {
      HttpClientRequest r = await new HttpClient().openUrl(method, uri);
      this.headers.forEach((k, v) => r.headers.add(k, v));

      if (this.body != null) {

        r..write(jsonEncode(this.fields));
        
        this.files.forEach((f) => r.addStream(f));

        return HttpResponse._fromResponse(this,
            await r.close());
      } else {
        return HttpResponse._fromResponse(
            this,
            await r.close());
      }
    } on Exception {
      return HttpResponse._fromResponse(
          this, null);
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
    super.finish();
  }
}

/// A HTTP response. More documentation can be found at the
/// [w_transport docs](https://www.dartdocs.org/documentation/w_transport/3.0.0/w_transport/Response-class.html)
class HttpResponse {
  /// The HTTP request.
  HttpBase request;

  /// Whether or not the request was aborted. If true, all other fields will be null.
  bool aborted;

  String statusText;

  int status;

  HttpHeaders headers;

  Map<String, dynamic> body;

  HttpResponse._new(this.request, this.status, this.statusText,
      this.headers, this.body,
      [this.aborted = false]);

  HttpResponse._aborted(this.request, [this.aborted = true]) {
        this.status = 0;
        this.statusText = "ABORTED";
        this.headers = null;
        this.body = null;
  }

  static Future<HttpResponse> _fromResponse(HttpBase request, HttpClientResponse r) async {
    return new HttpResponse._new(
        request, r.statusCode, "", r.headers, jsonDecode(await r.transform(utf8.decoder).first) as Map<String, dynamic>);
  }
}

/// A bucket for managing ratelimits.
class HttpBucket {
  /// The url that this bucket is handling requests for.
  String url;

  /// The number of requests that can be made.
  int limit;

  /// The number of remaining requests that can be made. May not always be accurate.
  int rateLimitRemaining = 1;

  /// When the ratelimits reset.
  DateTime rateLimitReset;

  /// The time difference between you and Discord.
  Duration timeDifference;

  /// A queue of requests waiting to be sent.
  List<HttpBase> requests = <HttpBase>[];

  /// Whether or not the bucket is waiting for a request to complete
  /// before continuing.
  bool waiting = false;

  HttpBucket._new(this.url);

  void _push(HttpRequest request) {
    this.requests.add(request);
    this._handle();
  }

  void _handle() {
    if (this.waiting || this.requests.length == 0) return;
    this.waiting = true;

    this._execute(this.requests[0]);
  }

  void _execute(HttpBase request) {
    if (this.rateLimitRemaining == null || this.rateLimitRemaining > 0) {
      request._execute().then((HttpResponse r) {
        this.limit = r.headers.value('x-ratelimit-limit') != null
            ? int.parse(r.headers.value('x-ratelimit-limit'))
            : null;
        this.rateLimitRemaining = r.headers.value('x-ratelimit-remaining') != null
            ? int.parse(r.headers.value('x-ratelimit-remaining'))
            : null;
        this.rateLimitReset = r.headers.value('x-ratelimit-reset') != null
            ? new DateTime.fromMillisecondsSinceEpoch(
                int.parse(r.headers.value('x-ratelimit-reset')) * 1000,
                isUtc: true)
            : null;
        try {
          this.timeDifference = new DateTime.now()
              .toUtc()
              .difference(http_parser.parseHttpDate(r.headers.value('date')).toUtc());
        } catch (err) {
          this.timeDifference = new Duration();
        }

        if (r.status == 429) {
          new RatelimitEvent._new(
              request.http._client, request as HttpRequest, false, r);
          new Timer(
              new Duration(
                  milliseconds: (r.body['retry_after'] as int) + 500),
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
          this.rateLimitReset.difference(new DateTime.now().toUtc()) +
              this.timeDifference +
              new Duration(milliseconds: 1000);
      if (waitTime.isNegative) {
        this.rateLimitRemaining = 1;
        this._execute(request);
      } else {
        new RatelimitEvent._new(
            request.http._client, request as HttpRequest, true);
        new Timer(waitTime, () {
          this.rateLimitRemaining = 1;
          this._execute(request);
        });
      }
    }
  }
}

/// The client's HTTP client.
class Http {
  Client _client;

  /// The buckets.
  Map<String, HttpBucket> buckets = <String, HttpBucket>{};

  /// Headers sent on every request.
  Map<String, String> headers;

  Logger _logger = new Logger.detached("Http");

  Http._new([this._client]) {
    this.headers = <String, String>{'Content-Type': 'application/json'};
    this.headers['User-Agent'] =
        'DiscordBot (https://github.com/l7ssha/nyxx, ${_Constants.version})';
  }

  /// Sends a HTTP request.
  Future<HttpResponse> send(String method, String path,
      {dynamic body,
      Map<String, String> queryParams,
      bool beforeReady: false,
      Map<String, String> headers: const {},
      String reason}) async {
    if (_client is Client && !this._client.ready && !beforeReady)
      throw new Exception("Client isn't ready yet.");

    HttpRequest request = new HttpRequest._new(
        this,
        method,
        path,
        queryParams,
        new Map.from(this.headers)
          ..addAll(headers)
          ..addAll(addAuditReason(reason)),
        body);

    await for (HttpResponse r in request.stream) {
      if (!r.aborted && r.status >= 200 && r.status < 300) {
        if (_client != null) new HttpResponseEvent._new(_client, r);
        return r;
      } else {
        if (_client != null) new HttpErrorEvent._new(_client, r);
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  /// Expands shorten attachment string `{finename}`
  /// to full format `attachment://filename`
  String expandAttachments(String payload) {
    return payload.replaceAllMapped(new RegExp(r'\{(.+)\}'), (match) {
      return "attachment://${match.group(0)}";
    });
  }

  /// Adds AUDIT_LOG header to request
  Map<String, String> addAuditReason(String reason) =>
      <String, String>{"X-Audit-Log-Reason": "$reason"};

  /// Sends mutlipart response
  Future<HttpResponse> sendMultipart(
      String method, String path, List<String> filenames,
      {String data, bool beforeReady: false, String reason}) async {
    if (_client is Client && !this._client.ready && !beforeReady)
      throw new Exception("Client isn't ready yet.");

    Directory current = Directory.current;
    List<String> filepaths = new List();

    for (var name in filenames) filepaths.add("${current.path}/$name");

    HttpMultipartRequest request = new HttpMultipartRequest._new(
        this,
        method,
        path,
        filenames,
        filepaths,
        <String, String>{"payload_json": expandAttachments(data)},
        new Map.from(this.headers)
          ..addAll(headers)
          ..addAll(addAuditReason(reason)));

    await for (HttpResponse r in request.stream) {
      if (!r.aborted && r.status >= 200 && r.status < 300) {
        if (_client != null) new HttpResponseEvent._new(_client, r);
        return r;
      } else {
        if (_client != null) new HttpErrorEvent._new(_client, r);
        throw new HttpError._new(r);
      }
    }
    return null;
  }
}
