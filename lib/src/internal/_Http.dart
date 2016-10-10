part of discord;

class _HttpRequest {
  http.Client client;
  String uri;
  String method;
  Map<String, String> headers;
  dynamic body;
  Function execute;
  StreamController<http.Response> streamController;
  Stream<http.Response> stream;

  _HttpRequest(this.client, this.uri, this.method, this.headers, this.body) {
    this.streamController = new StreamController<http.Response>();
    this.stream = streamController.stream;

    if (this.method == "GET") {
      this.execute = () async {
        return await this
            .client
            .get("${_Constants.host}$uri", headers: this.headers);
      };
    } else if (this.method == "POST") {
      this.execute = () async {
        return await this.client.post("${_Constants.host}$uri",
            body: JSON.encode(this.body), headers: this.headers);
      };
    } else if (this.method == "PATCH") {
      this.execute = () async {
        return await this.client.patch("${_Constants.host}$uri",
            body: JSON.encode(this.body), headers: this.headers);
      };
    } else if (this.method == "DELETE") {
      this.execute = () async {
        return await this
            .client
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
    if (this.ratelimitRemaining > 0) {
      request.execute().then((http.Response r) {
        this.ratelimitRemaining = r.headers['x-ratelimit-remaining'] != null
            ? int.parse(r.headers['x-ratelimit-remaining'])
            : null;
        this.ratelimitReset = r.headers['x-ratelimit-reset'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(
                int.parse(r.headers['x-ratelimit-reset']) * 1000,
                isUtc: true)
            : null;
        this.timeDifference = new DateTime.now()
            .difference(http_parser.parseHttpDate(r.headers['date']));

        if (r.statusCode == 429) {
          new Timer(
              new Duration(
                  milliseconds: int.parse(r.headers['retry-after']) + 100),
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
              new Duration(milliseconds: 100);
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

/// The HTTP manager for the client.
class _Http {
  Map<String, _Bucket> buckets = <String, _Bucket>{};

  /// A map of headers that get sent on each HTTP request.
  Map<String, String> headers;

  /// The HTTP client.
  http.Client client;

  /// Makes a new HTTP manager.
  _Http(Client client) {
    this.client = new http.Client();
    this.headers = <String, String>{
      'User-Agent':
          'Discord Dart (https://github.com/Hackzzila/Discord-Dart, ${client.version})',
      'Content-Type': 'application/json'
    };
  }

  /// Sends a GET request.
  Future<http.Response> get(String uri) async {
    if (buckets[uri] == null) {
      buckets[uri] = new _Bucket(uri);
    }

    await for (http.Response r in buckets[uri]
        .push(new _HttpRequest(this.client, uri, "GET", this.headers, null))) {
      return r;
    }
    return null;
  }

  /// Sends a POST request.
  Future<http.Response> post(String uri, Object content) async {
    //return await this.client.post("${this.host}$uri",
    //    body: JSON.encode(content), headers: this.headers);
    if (buckets[uri] == null) {
      buckets[uri] = new _Bucket(uri);
    }

    await for (http.Response r in buckets[uri].push(
        new _HttpRequest(this.client, uri, "POST", this.headers, content))) {
      return r;
    }
    return null;
  }

  /// Sends a PATCH request.
  Future<http.Response> patch(String uri, Object content) async {
    //return await this.client.patch("${this.host}$uri",
    //    body: JSON.encode(content), headers: this.headers);
    if (buckets[uri] == null) {
      buckets[uri] = new _Bucket(uri);
    }

    await for (http.Response r in buckets[uri].push(
        new _HttpRequest(this.client, uri, "PATCH", this.headers, content))) {
      return r;
    }
    return null;
  }

  /// Sends a DELETE request.
  Future<http.Response> delete(String uri) async {
    //return await this.client.delete("${this.host}$uri", headers: this.headers);
    if (buckets[uri] == null) {
      buckets[uri] = new _Bucket(uri);
    }

    await for (http.Response r in buckets[uri].push(
        new _HttpRequest(this.client, uri, "DELETE", this.headers, null))) {
      return r;
    }
    return null;
  }
}
