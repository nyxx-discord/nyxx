import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Represents a HTTP result from the API.
abstract class IHttpResponse {
  /// The status code of the response.
  int get statusCode;

  /// The headers associated with the response.
  Map<String, String> get headers;

  /// The body of this response.
  ///
  /// See also:
  /// - [textBody], for getting the body decoded as a [String].
  /// - [jsonBody], for decoding the body decoded as JSON.
  Uint8List get body;

  /// The body of this response, decoded as UTF-8.
  ///
  /// Will be `null` if the body was not valid UTF-8.
  ///
  /// See also:
  /// - [jsonBody], for getting the body decoded as JSON.
  String? get textBody;

  /// The body of this response, decoded as JSON.
  ///
  /// Will be `null` is the body was not valid JSON, and [hasJsonBody] will be set to `false`.
  dynamic get jsonBody;

  /// Whether this response has a JSON body.
  bool get hasJsonBody;
}

abstract class HttpResponse implements IHttpResponse {
  @override
  final int statusCode;

  @override
  final Map<String, String> headers;

  @override
  final Uint8List body;

  @override
  late final String? textBody;

  @override
  late final dynamic jsonBody;

  @override
  late final bool hasJsonBody;

  final http.BaseResponse response;
  http.BaseRequest get request => response.request!;

  HttpResponse({
    required this.response,
    required this.body,
  })  : statusCode = response.statusCode,
        headers = response.headers {
    String? textBody;
    dynamic jsonBody;
    bool hasJsonBody = false;

    try {
      textBody = utf8.decode(body);
      jsonBody = jsonDecode(textBody);
      hasJsonBody = true;
    } on FormatException {
      // ignore: Invalid format, leave the defaults
    }

    this.textBody = textBody;
    this.jsonBody = jsonBody;
    this.hasJsonBody = hasJsonBody;
  }

  @override
  String toString() => '$statusCode (${response.reasonPhrase}) ${request.method} ${request.url}';
}

/// A successful HTTP response.
abstract class IHttpResponseSuccess implements IHttpResponse {}

class HttpResponseSuccess extends HttpResponse implements IHttpResponseSuccess {
  HttpResponseSuccess({required super.body, required super.response});

  static Future<HttpResponseSuccess> fromResponse(http.StreamedResponse response) async => HttpResponseSuccess(
        body: await response.stream.toBytes(),
        response: response,
      );
}

abstract class IHttpResponseError implements IHttpResponse, Exception {
  /// Message why http request failed
  String get message;

  @Deprecated('Use errorCode instead')
  int get code;

  /// Error code of response
  ///
  /// If Discord sets its own status code, this can be found here. Otherwise, this is equal to [statusCode].
  int get errorCode;
}

/// Returned when client fails to execute http request.
/// Will contain reason why request failed.
class HttpResponseError extends HttpResponse implements IHttpResponseError {
  @override
  String get message => (jsonBody?['message'] as String?) ?? response.reasonPhrase ?? textBody!;

  @override
  int get errorCode => (jsonBody?['code'] as int?) ?? statusCode;

  @override
  int get code => errorCode;

  HttpResponseError({required super.body, required super.response});

  static Future<HttpResponseError> fromResponse(http.StreamedResponse response) async => HttpResponseError(
        body: await response.stream.toBytes(),
        response: response,
      );

  @override
  String toString() => '$errorCode ($message) ${request.method} ${request.url}';
}
