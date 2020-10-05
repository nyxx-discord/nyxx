part of nyxx;

abstract class _HttpRequest {
  late final Uri uri;
  final String method;
  final Map<String, dynamic>? queryParams;
  final String? auditLog;

  final bool rateLimit;

  // Injected by the HttpHandler
  late _HttpClient _client;

  _HttpRequest._new(String path, {this.method = "GET", this.queryParams, this.auditLog, this.rateLimit = true}) {
    this.uri = Uri.https(Constants.host, Constants.baseUri + path);
  }

  Map<String, String> _genHeaders() => {
    if (this.auditLog != null) "X-Audit-Log-Reason": this.auditLog!,
    "User-Agent": "Nyxx (${Constants.repoUrl}, ${Constants.version})"
  };

  Future<http.StreamedResponse> _execute();
}

/// [BasicRequest] with json body
class BasicRequest extends _HttpRequest {
  /// Body of request
  final dynamic body;

  BasicRequest._new(String path,
      {String method = "GET", this.body, Map<String, dynamic>? queryParams, String? auditLog, bool rateLimit = true})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog, rateLimit: rateLimit);

  @override
  Future<http.StreamedResponse> _execute() async {
    final request = http.Request(this.method, this.uri..replace(queryParameters: queryParams))
      ..headers.addAll(_genHeaders());

    if (this.body != null && this.method != "GET") {
      request.headers.addAll(_getJsonContentTypeHeader());
      if (this.body is String) {
        request.body = this.body as String;
      } else
      if (this.body is Map<String, dynamic> || this.body is List<dynamic>) {
        request.body = jsonEncode(this.body);
      }
    }

    return this._client.send(request);
  }
  
  Map<String, String> _getJsonContentTypeHeader() => {
    "Content-Type" : "application/json"
  };
}

/// Request with which files will be sent. Cannot contain request body.
class MultipartRequest extends _HttpRequest {
  /// Files which will be sent
  final List<AttachmentBuilder> files;

  /// Additional data to sent
  final Map<String, dynamic>? fields;

  MultipartRequest._new(String path, this.files,
      {this.fields, String method = "GET", Map<String, dynamic>? queryParams, String? auditLog, bool rateLimit = true})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog, rateLimit: rateLimit);

  @override
  Future<http.StreamedResponse> _execute() {
    final request = http.MultipartRequest(this.method, this.uri..replace(queryParameters: queryParams))
      ..headers.addAll(_genHeaders());

    for (final file in this.files) {
      request.files.add(file._asMultipartFile());
    }

    if (this.fields != null) {
      request.fields.addAll({"payload_json": jsonEncode(this.fields)});
    }

    return this._client.send(request);
  }
}
