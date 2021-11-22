import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class HttpRequest {
  late final Uri uri;
  late final Map<String, String> headers;

  final String method;
  final RawApiMap? queryParams;
  final String? auditLog;

  final bool auth;
  final bool rateLimit;

  /// Creates and instance of [HttpRequest]
  HttpRequest(String path, {this.method = "GET", this.queryParams, Map<String, String>? headers, this.auditLog, this.rateLimit = true, this.auth = true}) {
    uri = Uri.https(Constants.host, Constants.baseUri + path);
    this.headers = headers ?? {};
  }

  Map<String, String> genHeaders() => {
    ...headers,
    if (auditLog != null) "X-Audit-Log-Reason": auditLog!,
    "User-Agent": "Nyxx (${Constants.repoUrl}, ${Constants.version})"
  };

  Future<http.BaseRequest> prepareRequest();
}

/// [BasicRequest] with json body
class BasicRequest extends HttpRequest {
  /// Body of request
  final dynamic body;

  BasicRequest(String path, {String method = "GET", this.body, RawApiMap? queryParams, String? auditLog, Map<String, String>? headers, bool rateLimit = true, bool auth = true})
      : super(path, method: method, queryParams: queryParams, auditLog: auditLog, headers: headers, rateLimit: rateLimit, auth: auth);

  @override
  Future<http.BaseRequest> prepareRequest() async {
    final request = http.Request(method, uri.replace(queryParameters: queryParams))..headers.addAll(genHeaders());

    if (body != null && method != "GET") {
      request.headers.addAll(_getJsonContentTypeHeader());
      if (body is String) {
        request.body = body as String;
      } else if (body is RawApiMap || body is List<dynamic>) {
        request.body = jsonEncode(body);
      }
    }

    return request;
  }

  Map<String, String> _getJsonContentTypeHeader() => {"Content-Type": "application/json"};
}

/// Request with which files will be sent. Cannot contain request body.
class MultipartRequest extends HttpRequest {
  /// Files which will be sent
  final List<http.MultipartFile> files;

  /// Additional data to sent
  final dynamic fields;

  /// Creates an instance of [MultipartRequest]
  MultipartRequest(String path, this.files, {this.fields, String method = "GET", RawApiMap? queryParams, Map<String, String>? headers, String? auditLog, bool auth = true, bool rateLimit = true})
      : super(path, method: method, queryParams: queryParams, headers: headers, auditLog: auditLog, rateLimit: rateLimit, auth: auth);

  @override
  Future<http.BaseRequest> prepareRequest() async {
    final request = http.MultipartRequest(method, uri.replace(queryParameters: queryParams))..headers.addAll(genHeaders());

    request.files.addAll(files);

    if (fields != null) {
      request.fields.addAll({"payload_json": jsonEncode(fields)});
    }

    return request;
  }
}
