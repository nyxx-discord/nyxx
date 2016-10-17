part of discord;

class _HttpRequest {
  _Http http;
  String uri;
  String method;
  Map<String, String> headers;
  dynamic body;
  Function execute;
  StreamController<http.Response> streamController;
  Stream<http.Response> stream;

  _HttpRequest(this.http, this.uri, this.method, this.headers, this.body) {
    this.streamController = new StreamController<http.Response>();
    this.stream = streamController.stream;

    if (this.method == "GET") {
      this.execute = () async {
        return await this
            .http
            .httpClient
            .get("${this.http.host}$uri", headers: this.headers);
      };
    } else if (this.method == "POST") {
      this.execute = () async {
        return await this.http.httpClient.post("${this.http.host}$uri",
            body: JSON.encode(this.body), headers: this.headers);
      };
    } else if (this.method == "PATCH") {
      this.execute = () async {
        return await this.http.httpClient.patch("${this.http.host}$uri",
            body: JSON.encode(this.body), headers: this.headers);
      };
    } else if (this.method == "PUT") {
      this.execute = () async {
        return await this.http.httpClient.put("${this.http.host}$uri",
            body: JSON.encode(this.body), headers: this.headers);
      };
    } else if (this.method == "DELETE") {
      this.execute = () async {
        return await this
            .http
            .httpClient
            .delete("${_Constants.host}$uri", headers: this.headers);
      };
    }
  }
}

class _Bucket {
  String uri;
  int ratelimitRemaining = 1;
  DateTime ratelimitReset;
  Duration timeDifference;
  List<_HttpRequest> requests = <_HttpRequest>[];
  bool waiting = false;

  _Bucket(this.uri);

  Stream<http.Response> push(_HttpRequest request) {
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
    if (_browser ||
        (this.ratelimitRemaining == null || this.ratelimitRemaining > 0)) {
      request.execute().then((http.Response r) {
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

        if (r.statusCode == 429) {
          new Timer(
              new Duration(
                  milliseconds: JSON.decode(r.body)['retry_after'] + 500),
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

class _HttpResponse {
  http.Response response;
  dynamic json;

  _HttpResponse(this.response) {
    if (this.response.headers['content-type'] == "application/json") {
      this.json = JSON.decode(this.response.body);
    }
  }
}

/// The HTTP manager for the client.
class _Http {
  dynamic client;
  String host;
  Map<String, _Bucket> buckets = <String, _Bucket>{};

  /// A map of headers that get sent on each HTTP request.
  Map<String, String> headers;

  /// The HTTP client.
  _HttpClient httpClient;

  /// Makes a new HTTP manager.
  _Http(this.client, [this.host = _Constants.host]) {
    this.httpClient = new _HttpClient();
    this.headers = <String, String>{'Content-Type': 'application/json'};

    if (!_browser)
      this.headers['User-Agent'] =
          'Discord Dart (https://github.com/Hackzzila/Discord-Dart, ${client.version})';
  }

  /// Sends a GET request.
  Future<_HttpResponse> get(String uri, [bool beforeReady = false]) async {
    if (client is Client && !this.client.ready && !beforeReady)
      throw new ClientNotReadyError();
    if (buckets[uri] == null) buckets[uri] = new _Bucket(uri);

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this, uri, "GET", this.headers, null))) {
      http_utils.ResponseStatus status =
          http_utils.ResponseStatus.fromStatusCode(r.statusCode);
      if (status.family == http_utils.ResponseStatusFamily.SUCCESSFUL) {
        return new _HttpResponse(r);
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  /// Sends a POST request.
  Future<_HttpResponse> post(String uri, Object content,
      [bool beforeReady = false]) async {
    if (client is Client && !this.client.ready && !beforeReady)
      throw new ClientNotReadyError();
    if (buckets[uri] == null) buckets[uri] = new _Bucket(uri);

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this, uri, "POST", this.headers, content))) {
      http_utils.ResponseStatus status =
          http_utils.ResponseStatus.fromStatusCode(r.statusCode);
      if (status.family == http_utils.ResponseStatusFamily.SUCCESSFUL) {
        return new _HttpResponse(r);
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  /// Sends a PATCH request.
  Future<_HttpResponse> patch(String uri, Object content,
      [bool beforeReady = false]) async {
    if (client is Client && !this.client.ready && !beforeReady)
      throw new ClientNotReadyError();
    if (buckets[uri] == null) buckets[uri] = new _Bucket(uri);

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this, uri, "PATCH", this.headers, content))) {
      http_utils.ResponseStatus status =
          http_utils.ResponseStatus.fromStatusCode(r.statusCode);
      if (status.family == http_utils.ResponseStatusFamily.SUCCESSFUL) {
        return new _HttpResponse(r);
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  /// Sends a PUT request.
  Future<_HttpResponse> put(String uri, Object content,
      [bool beforeReady = false]) async {
    if (client is Client && !this.client.ready && !beforeReady)
      throw new ClientNotReadyError();
    if (buckets[uri] == null) buckets[uri] = new _Bucket(uri);

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this, uri, "PUT", this.headers, content))) {
      http_utils.ResponseStatus status =
          http_utils.ResponseStatus.fromStatusCode(r.statusCode);
      if (status.family == http_utils.ResponseStatusFamily.SUCCESSFUL) {
        return new _HttpResponse(r);
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  /// Sends a DELETE request.
  Future<_HttpResponse> delete(String uri, [bool beforeReady = false]) async {
    if (client is Client && !this.client.ready && !beforeReady)
      throw new ClientNotReadyError();
    if (buckets[uri] == null) buckets[uri] = new _Bucket(uri);

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this, uri, "DELETE", this.headers, null))) {
      http_utils.ResponseStatus status =
          http_utils.ResponseStatus.fromStatusCode(r.statusCode);
      if (status.family == http_utils.ResponseStatusFamily.SUCCESSFUL) {
        return new _HttpResponse(r);
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }
}
