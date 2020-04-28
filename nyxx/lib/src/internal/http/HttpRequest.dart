part of nyxx;

abstract class HttpRequest {
  late final Uri uri;
  final String method;
  final Map<String, String>? queryParams;
  final String? auditLog;

  Nyxx? _client;

  HttpRequest._new(String path, {this.method = "GET", this.queryParams, this.auditLog}) {
    this.uri = Uri.https(_Constants.host, _Constants.baseUri + path);
  }

  Map<String, String> _genHeaders() {
    return {
      "Authorization" : "Bot ${_client?._token}",
      if(this.auditLog != null) "X-Audit-Log-Reason" : this.auditLog!,
      "User-Agent" : "Nyxx (${_Constants.repoUrl}, ${_Constants.version})"
    };
  }

  Future<transport.Response> _execute();
}

class JsonRequest extends HttpRequest {
  final dynamic body;

  JsonRequest._new(String path, {String method = "GET", this.body, Map<String, String>? queryParams, String? auditLog})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog);

  @override
  Future<transport.Response> _execute() async {
    var request = transport.JsonRequest()
        ..uri = this.uri
        ..headers = _genHeaders();

    if(this.body != null) {
      request.body = this.body;
    }

    if(this.queryParams != null) {
      request.queryParameters = this.queryParams;
    }

    return request.send(this.method);
  }
}

class MultipartRequest extends HttpRequest {
  final List<AttachmentBuilder> files;

  final Map<String, dynamic>? fields;

  MultipartRequest._new(String path, this.files, {this.fields, String method = "GET", Map<String, String>? queryParams, String? auditLog})
      : super._new(path, method: method, queryParams: queryParams, auditLog: auditLog);

  Map<String, dynamic> _mapFiles() {
    return {
      for(var file in files)
        file._name : file._asMultipartFile()
    };
  }

  @override
  Future<transport.Response> _execute() {
    var request = transport.MultipartRequest()
        ..uri = this.uri
        ..headers = _genHeaders()
        ..files = _mapFiles();

    if(this.fields != null) {
      request.fields.addAll({"payload_json": jsonEncode(this.fields)});
    }

    return request.send(this.method);
  }
}