part of discord;

class _HttpRequest {
  Http http;
  _Bucket bucket;
  String path;
  Map<String, String> queryParams;
  Uri uri;
  String method;
  Map<String, String> headers;
  dynamic body;
  StreamController<w_transport.Response> streamController;
  Stream<w_transport.Response> stream;

  _HttpRequest(this.http, this.method, this.path, this.queryParams, this.headers, this.body) {
    this.uri = new Uri.https(_Constants.host, _Constants.baseUri + path, queryParams);
    
    if (http._buckets[uri.toString()] == null)
      http._buckets[uri.toString()] = new _Bucket(uri.toString());
      
    this.bucket = http._buckets[uri.toString()];
    
    this.streamController = new StreamController<w_transport.Response>();
    this.stream = streamController.stream;
    
    this.run();
  }
  
  void run() => this.bucket.push(this);
  
  Future<w_transport.Response> execute() async {
    try {
      if (this.body != null) {
        w_transport.JsonRequest r = new w_transport.JsonRequest()
          ..body = this.body;
        return await r.send(this.method,
            uri: this.uri, headers: this.headers);
      } else {
        return await w_transport.Http
            .send(this.method, this.uri, headers: this.headers);
      }
    } on w_transport.RequestException catch (err) {
      return err.response;
    }
  }
}

class _Bucket {
  String url;
  int ratelimitRemaining = 1;
  DateTime ratelimitReset;
  Duration timeDifference;
  List<_HttpRequest> requests = <_HttpRequest>[];
  bool waiting = false;

  _Bucket(this.url);

  Stream<w_transport.Response> push(_HttpRequest request) {
    this.requests.add(request);
    this.handle();
    return request.stream;
  }

  void handle() {
    if (this.waiting || this.requests.length == 0) return;
    this.waiting = true;

    this.execute(this.requests[0]);
  }

  void execute(_HttpRequest request) {
    if (this.ratelimitRemaining == null || this.ratelimitRemaining > 0) {
      request.execute().then((w_transport.Response r) {
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
              () => this.execute(request));
        } else {
          this.waiting = false;
          this.requests.remove(request);
          request.streamController.add(r);
          request.streamController.close();
          this.handle();
        }
      });
    } else {
      final Duration waitTime =
          this.ratelimitReset.difference(new DateTime.now().toUtc()) +
              this.timeDifference +
              new Duration(milliseconds: 1000);
      if (waitTime.isNegative) {
        this.ratelimitRemaining = 1;
        this.execute(request);
      } else {
        new Timer(waitTime, () {
          this.ratelimitRemaining = 1;
          this.execute(request);
        });
      }
    }
  }
}

/// The client's HTTP client.
class Http {
  dynamic _client;
  Map<String, _Bucket> _buckets = <String, _Bucket>{};

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

    await for (w_transport.Response r in new _HttpRequest(this, method, path, queryParams,
            new Map.from(this.headers)..addAll(headers), body).stream) {
      if (r.status >= 200 && r.status < 300) {
        return r;
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }
}
