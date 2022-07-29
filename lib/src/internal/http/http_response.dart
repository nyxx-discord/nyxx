import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class IHttpResponse {
  int get statusCode;
  Map<String, String> get headers;
}

abstract class HttpResponse implements IHttpResponse {
  @override
  late final int statusCode;
  @override
  late final Map<String, String> headers;

  late final List<int> _body;
  late final dynamic _jsonBody;
  late final http.ByteStream _bodyStream;

  /// Creates an instance of [HttpResponse]
  HttpResponse(http.StreamedResponse response) {
    _bodyStream = response.stream;
    statusCode = response.statusCode;
    headers = response.headers;
  }

  Future<void> finalize() async {
    _body = await _bodyStream.toBytes();

    try {
      if (_body.isNotEmpty) {
        _jsonBody = jsonDecode(utf8.decode(_body));
      } else {
        _jsonBody = null;
      }
    } on FormatException {
      _jsonBody = null;
    }
  }
}

abstract class IHttpResponseSuccess implements IHttpResponse {
  /// Body of response
  List<int> get body;

  /// Response body as json
  dynamic get jsonBody;
}

/// Returned when http request is successfully executed.
class HttpResponseSuccess extends HttpResponse implements IHttpResponseSuccess {
  /// Body of response
  @override
  List<int> get body => _body;

  /// Response body as json
  @override
  dynamic get jsonBody => _jsonBody;

  /// Creates an instance of [HttpResponseSuccess]
  HttpResponseSuccess(http.StreamedResponse response) : super(response);
}

abstract class IHttpResponseError implements IHttpResponse, Exception {
  /// Message why http request failed
  String get message;

  /// Error code of response
  int get code;
}

/// Returned when client fails to execute http request.
/// Will contain reason why request failed.
class HttpResponseError extends HttpResponse implements IHttpResponseError {
  /// Message why http request failed
  @override
  late String message;

  /// Error code of response
  @override
  late int code;

  /// Creates an instance of [HttpResponseError]
  HttpResponseError(http.StreamedResponse response) : super(response) {
    if (response.headers["Content-Type"] == "application/json") {
      code = _jsonBody["code"] as int;
      message = _jsonBody["message"] as String;
    } else {
      message = "";
      code = response.statusCode;
    }
  }

  @override
  Future<void> finalize() async {
    await super.finalize();

    if (message.isEmpty) {
      try {
        message = utf8.decode(_body);
      } on Exception {} // ignore: empty_catches
    }
  }

  @override
  String toString() => "[Code: $code] [Message: $message]";
}
