import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/internal/http/http_route.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class HttpRequest {
  late final Uri uri;
  late final Map<String, String> headers;

  final String method;
  final RawApiMap? queryParams;
  final String? auditLog;

  final bool auth;
  final bool globalRateLimit;
  final HttpRoute route;
  String get rateLimitId => method + route.routeId;

  /// Creates and instance of [HttpRequest]
  HttpRequest(this.route, {this.method = "GET", this.queryParams, Map<String, String>? headers, this.auditLog, this.globalRateLimit = true, this.auth = true}) {
    uri = Uri.https(Constants.host, Constants.baseUri + route.path);
    this.headers = headers ?? {};
  }

  Map<String, String> genHeaders() =>
      {...headers, if (auditLog != null) "X-Audit-Log-Reason": auditLog!, "User-Agent": "Nyxx (${Constants.repoUrl}, ${Constants.version})"};

  Future<http.BaseRequest> prepareRequest();

  @override
  String toString() => '$method $uri';
}

/// [BasicRequest] with json body
class BasicRequest extends HttpRequest {
  /// Body of request
  final dynamic body;

  BasicRequest(HttpRoute route,
      {String method = "GET", this.body, RawApiMap? queryParams, String? auditLog, Map<String, String>? headers, bool globalRateLimit = true, bool auth = true})
      : super(route, method: method, queryParams: queryParams, auditLog: auditLog, headers: headers, globalRateLimit: globalRateLimit, auth: auth);

  @override
  Future<http.BaseRequest> prepareRequest() async {
    final request = http.Request(method, uri.replace(queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString()))))
      ..headers.addAll(genHeaders());

    if (body != null && method != "GET") {
      request.headers.addAll(_getJsonContentTypeHeader());
      if (body is String) {
        request.body = body as String;
      } else if (body is RawApiMap || body is RawApiList) {
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
  MultipartRequest(HttpRoute route, this.files,
      {this.fields,
      String method = "GET",
      RawApiMap? queryParams,
      Map<String, String>? headers,
      String? auditLog,
      bool auth = true,
      bool globalRateLimit = true})
      : super(route, method: method, queryParams: queryParams, headers: headers, auditLog: auditLog, globalRateLimit: globalRateLimit, auth: auth);

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
