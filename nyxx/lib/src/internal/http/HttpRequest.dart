part of nyxx;

abstract class _HttpRequest {
  late final Uri uri;
  final String method;
  final Map<String, dynamic>? queryParams;
  final String? auditLog;

  final bool ratelimit;

  late Nyxx _client;

  _HttpRequest._new(String path, {this.method = "GET", this.queryParams, this.auditLog, this.ratelimit = true}) {
    this.uri = Uri.https(Constants.host, Constants.baseUri + path);
  }

  Map<String, String> _genHeaders() => {
    "Authorization": "Bot ${_client._token}",
    if (this.auditLog != null) "X-Audit-Log-Reason": this.auditLog!,
    "User-Agent": "Nyxx (${Constants.repoUrl}, ${Constants.version})"
  };

  Future<transport.Response> _execute();
}

/// [BasicRequest] with json body
class BasicRequest extends _HttpRequest {
  /// Body of request
  final dynamic body;

  BasicRequest._new(String path,
      {String method = "GET", this.body, Map<String, dynamic>? queryParams, String? auditLog, bool ratelimit = true})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog, ratelimit: ratelimit);

  @override
  Future<transport.Response> _execute() async {
    final request = transport.JsonRequest()
      ..uri = this.uri
      ..headers = _genHeaders();

    if (this.body != null) {
      request.body = this.body;
    }

    if (this.queryParams != null) {
      this.queryParams!.forEach((key, value) {
        request.updateQuery({key: value});
      });
    }

    return request.send(this.method);
  }
}

/// Request with which files will be sent. Cannot contain request body.
class MultipartRequest extends _HttpRequest {
  /// Files which will be sent
  final List<AttachmentBuilder> files;

  /// Additional data to sent
  final Map<String, dynamic>? fields;

  MultipartRequest._new(String path, this.files,
      {this.fields, String method = "GET", Map<String, dynamic>? queryParams, String? auditLog})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog);

  Map<String, dynamic> _mapFiles() => {
    for (var file in files)
      file._name: file._asMultipartFile()
  };

  @override
  Future<transport.Response> _execute() {
    final request = transport.MultipartRequest()
      ..uri = this.uri
      ..headers = _genHeaders()
      ..files = _mapFiles();

    if (this.fields != null) {
      request.fields.addAll({"payload_json": jsonEncode(this.fields)});
    }

    return request.send(this.method);
  }
}
