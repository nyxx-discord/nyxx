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
    this._bodyStream = response.stream;
    this.statusCode = response.statusCode;
    this.headers = response.headers;
  }

  Future<void> finalize() async {
    this._body = await _bodyStream.toBytes();

    try {
      if (this._body.isNotEmpty) {
        this._jsonBody = jsonDecode(utf8.decode(this._body));
      } else {
        this._jsonBody = null;
      }
    } on FormatException {
      this._jsonBody = null;
    }
  }
}

abstract class IHttpResponseSucess implements IHttpResponse {
  /// Body of response
  List<int> get body;

  /// Response body as json
  dynamic get jsonBody;
}

/// Returned when http request is successfully executed.
class HttpResponseSuccess extends HttpResponse implements IHttpResponseSucess {
  /// Body of response
  @override
  List<int> get body => this._body;

  /// Response body as json
  @override
  dynamic get jsonBody => this._jsonBody;

  /// Creates an instance of [HttpResponseSuccess]
  HttpResponseSuccess(http.StreamedResponse response) : super(response);
}

abstract class IHttpResponseError implements IHttpResponse, Error {
  /// Message why http request failed
  String get errorMessage;

  /// Error code of response
  int get errorCode;
}

/// Returned when client fails to execute http request.
/// Will contain reason why request failed.
class HttpResponseError extends HttpResponse implements IHttpResponseError {
  /// Message why http request failed
  @override
  late String errorMessage;

  /// Error code of response
  @override
  late int errorCode;

  /// Creates an instance of [HttpResponseError]
  HttpResponseError(http.StreamedResponse response) : super(response) {
    if (response.headers["Content-Type"] == "application/json") {
      this.errorCode = this._jsonBody["code"] as int;
      this.errorMessage = this._jsonBody["message"] as String;
    } else {
      this.errorMessage = "";
      this.errorCode = response.statusCode;
    }
  }

  @override
  Future<void> finalize() async {
    await super.finalize();

    if (this.errorMessage.isEmpty) {
      try {
        this.errorMessage = utf8.decode(this._body);
      } on Exception {} // ignore: empty_catches
    }
  }

  @override
  String toString() => "[Code: $errorCode] [Message: $errorMessage]";

  @override
  StackTrace? get stackTrace => null;
}
