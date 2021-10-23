import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nyxx/src/internal/Constants.dart';
import 'package:nyxx/src/internal/http/HttpClient.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class HttpRequest {
  late final Uri uri;
  final String method;
  final RawApiMap? queryParams;
  final String? auditLog;

  final bool rateLimit;

  // Injected by the HttpHandler
  late InternalHttpClient _client;

  /// Creates and instance of [HttpRequest]
  HttpRequest(String path, {this.method = "GET", this.queryParams, this.auditLog, this.rateLimit = true}) {
    this.uri = Uri.https(Constants.host, Constants.baseUri + path);
  }

  Map<String, String> genHeaders() => {
    if (this.auditLog != null) "X-Audit-Log-Reason": this.auditLog!,
    "User-Agent": "Nyxx (${Constants.repoUrl}, ${Constants.version})"
  };

  Future<http.StreamedResponse> execute();

  void passClient(InternalHttpClient client) => _client = client;
}

/// [BasicRequest] with json body
class BasicRequest extends HttpRequest {
  /// Body of request
  final dynamic body;

  BasicRequest(String path,
      {String method = "GET", this.body, RawApiMap? queryParams, String? auditLog, bool rateLimit = true})
      : super(path, method: method, queryParams: queryParams, auditLog: auditLog, rateLimit: rateLimit);

  @override
  Future<http.StreamedResponse> execute() async {
    final request = http.Request(this.method, this.uri.replace(queryParameters: queryParams))
      ..headers.addAll(genHeaders());

    if (this.body != null && this.method != "GET") {
      request.headers.addAll(_getJsonContentTypeHeader());
      if (this.body is String) {
        request.body = this.body as String;
      } else
      if (this.body is RawApiMap || this.body is List<dynamic>) {
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
class MultipartRequest extends HttpRequest {
  /// Files which will be sent
  final List<http.MultipartFile> files;

  /// Additional data to sent
  final dynamic fields;

  /// Creates an instance of [MultipartRequest]
  MultipartRequest(String path, this.files,
      {this.fields, String method = "GET", RawApiMap? queryParams, String? auditLog, bool rateLimit = true})
      : super(path, method: method, queryParams: queryParams, auditLog: auditLog, rateLimit: rateLimit);

  @override
  Future<http.StreamedResponse> execute() {
    final request = http.MultipartRequest(this.method, this.uri.replace(queryParameters: queryParams))
      ..headers.addAll(genHeaders());

    request.files.addAll(this.files);

    if (this.fields != null) {
      request.fields.addAll({"payload_json": jsonEncode(this.fields)});
    }

    return this._client.send(request);
  }
}
