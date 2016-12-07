part of discord;

/// A HTTP request.
class HttpRequest {
  StreamController<w_transport.Response> _streamController;

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
  Stream<w_transport.Response> stream;

  HttpRequest._new(this.http, this.method, this.path, this.queryParams,
      this.headers, this.body) {
    this.uri =
        new Uri.https(_Constants.host, _Constants.baseUri + path, queryParams);

    if (http.buckets[uri.toString()] == null)
      http.buckets[uri.toString()] = new HttpBucket._new(uri.toString());

    this.bucket = http.buckets[uri.toString()];

    this._streamController =
        new StreamController<w_transport.Response>.broadcast();
    this.stream = _streamController.stream;

    new BeforeHttpRequestSendEvent._new(this.http._client, this);

    if (!this.http._client._events.beforeHttpRequestSend.hasListener)
      this.send();
  }

  /// Sends the request off to the bucket to be processed and sent.
  void send() => this.bucket._push(this);

  Future<w_transport.Response> _execute() async {
    try {
      if (this.body != null) {
        w_transport.JsonRequest r = new w_transport.JsonRequest()
          ..body = this.body;
        return await r.send(this.method, uri: this.uri, headers: this.headers);
      } else {
        return await w_transport.Http
            .send(this.method, this.uri, headers: this.headers);
      }
    } on w_transport.RequestException catch (err) {
      return err.response;
    }
  }
}

/// A bucket for managing ratelimits.
class HttpBucket {
  /// The url that this bucket is handling requests for.
  String url;

  /// How many requests remain before ratelimits take affect. May not always be accurate.
  int ratelimitRemaining = 1;

  /// When the ratelimits reset.
  DateTime ratelimitReset;

  /// The time difference between you and Discord.
  Duration timeDifference;

  /// A queue of requests waiting to be sent.
  List<HttpRequest> requests = <HttpRequest>[];

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

  void _execute(HttpRequest request) {
    if (this.ratelimitRemaining == null || this.ratelimitRemaining > 0) {
      request._execute().then((w_transport.Response r) {
        this.ratelimitRemaining = r.headers['x-ratelimit-remaining'] != null
            ? int.parse(r.headers['x-ratelimit-remaining'])
            : null;
        this.ratelimitReset = r.headers['x-ratelimit-reset'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(
                int.parse(r.headers['x-ratelimit-reset']) * 1000,
                isUtc: true)
            : null;
        try {
          this.timeDifference = new DateTime.now()
              .toUtc()
              .difference(http_parser.parseHttpDate(r.headers['date']).toUtc());
        } catch (err) {
          this.timeDifference = new Duration();
        }

        if (r.status == 429) {
          new Timer(
              new Duration(milliseconds: r.body.asJson()['retry_after'] + 500),
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
          this.ratelimitReset.difference(new DateTime.now().toUtc()) +
              this.timeDifference +
              new Duration(milliseconds: 1000);
      if (waitTime.isNegative) {
        this.ratelimitRemaining = 1;
        this._execute(request);
      } else {
        new Timer(waitTime, () {
          this.ratelimitRemaining = 1;
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

  Http._new([this._client]) {
    this.headers = <String, String>{'Content-Type': 'application/json'};

    if (!internals['browser'])
      headers['User-Agent'] =
          'nyx (https://github.com/Hackzzila/nyx, ${_Constants.version})';
  }

  /// Sends a HTTP request.
  Future<w_transport.Response> send(String method, String path,
      {dynamic body,
      Map<String, String> queryParams,
      bool beforeReady: false,
      Map<String, String> headers: const {}}) async {
    if (_client is Client && !this._client.ready && !beforeReady)
      throw new ClientNotReadyError();

    HttpRequest request = new HttpRequest._new(this, method, path, queryParams,
        new Map.from(this.headers)..addAll(headers), body);

    await for (w_transport.Response r in request.stream) {
      if (r.status >= 200 && r.status < 300) {
        if (_client != null) new HttpResponseEvent._new(_client, request, r);
        return r;
      } else {
        if (_client != null) new HttpErrorEvent._new(_client, request, r);
        throw new HttpError._new(r);
      }
    }
    return null;
  }
}
