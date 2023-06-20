import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/request.dart';

/// A response to a [HttpRequest] from the Discord API.
///
/// {@template http_response}
/// This class is a wrapper around [BaseResponse] from `package:http` providing support for errors
/// and for parsing the received body.
/// {@endtemplate}
abstract class HttpResponse {
  /// The status code of the response.
  final int statusCode;

  /// The headers from the response.
  final Map<String, String> headers;

  /// The body of the response as it was received from the API.
  final Uint8List body;

  /// The UTF-8 decoded body of the response.
  ///
  /// Will be null if [body] is not a valid UTF-8 string.
  late final String? textBody;

  /// The JSON decoded body of the response.
  ///
  /// Will be `null` and [hasJsonBody] will be false if [textBody] is not a valid JSON string.
  late final dynamic jsonBody;

  /// Whether [jsonBody] contains the JSON decoded body of the response.
  late final bool hasJsonBody;

  /// The [HttpRequest] this response is for.
  final HttpRequest request;

  /// The [BaseResponse] from `package:http` this [HttpResponse] is wrapping.
  final BaseResponse response;

  /// Create a new [HttpResponse].
  ///
  /// {@macro http_response}
  HttpResponse({
    required this.response,
    required this.request,
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
  String toString() => '$statusCode (${response.reasonPhrase}) ${request.method} ${response.request!.url}';
}

/// A successful [HttpResponse].
class HttpResponseSuccess extends HttpResponse {
  /// Create a new [HttpResponseSuccess].
  HttpResponseSuccess({required super.response, required super.request, required super.body});

  /// Create a [HttpResponseSuccess] from a [StreamedResponse].
  static Future<HttpResponseSuccess> fromResponse(
    HttpRequest request,
    StreamedResponse response,
  ) async =>
      HttpResponseSuccess(
        request: request,
        body: await response.stream.toBytes(),
        response: response,
      );
}

/// An [HttpResponse] which represents an error from the API.
class HttpResponseError extends HttpResponse implements NyxxException {
  /// A message containing details about why the request failed.
  @override
  String get message => errorData?.errorMessage ?? response.reasonPhrase ?? textBody!;

  /// The error code of this response.
  ///
  /// If Discord sets its own status code, this can be found here. Otherwise, this is equal to
  /// [statusCode].
  int get errorCode => errorData?.errorCode ?? statusCode;

  /// Additional information about the error, if any.
  late final HttpErrorData? errorData;

  /// Create a new [HttpResponseError].
  HttpResponseError({required super.response, required super.request, required super.body}) {
    HttpErrorData? errorData;
    if (hasJsonBody) {
      try {
        errorData = HttpErrorData.parse(jsonBody as Map<String, Object?>);
      } on TypeError {
        // ignore: Response was not a valid error object. We'll just fall back to the response status code and message.
      }
    }

    this.errorData = errorData;
  }

  /// Create a new [HttpResponseError] from a [StreamedResponse].
  static Future<HttpResponseError> fromResponse(
    HttpRequest request,
    StreamedResponse response,
  ) async =>
      HttpResponseError(
        request: request,
        body: await response.stream.toBytes(),
        response: response,
      );

  @override
  String toString({bool short = false}) {
    if (short) {
      return super.toString();
    }

    final result = StringBuffer('$message ($errorCode) ${request.method} ${response.request!.url}\n');

    if (errorData?.fieldErrors.isNotEmpty ?? false) {
      result.writeln('Errors:');

      for (final field in errorData!.fieldErrors.values) {
        result.writeln('  ${field.name}: ${field.errorMessage} (${field.errorCode})');
      }
    }

    // Trim trailing newline
    return result.toString().trim();
  }
}

/// Information about an error from the API.
class HttpErrorData {
  /// The error code.
  ///
  /// You can find a full list of these [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#json).
  final int errorCode;

  /// A human-readable description of the error represented by [errorCode].
  final String errorMessage;

  /// A mapping of field path to field error.
  ///
  /// Will be empty if Discord did not send any errors associated with specific fields in the request.
  final Map<String, FieldError> fieldErrors = {};

  /// Parse a JSON error response to an instance of [HttpErrorData].
  ///
  /// Throws a [TypeError] if [raw] is not a valid error response.
  HttpErrorData.parse(Map<String, Object?> raw)
      : errorCode = raw['code'] as int,
        errorMessage = raw['message'] as String {
    final errors = raw['errors'] as Map<String, Object?>?;

    if (errors != null) {
      _initErrors(errors);
    }
  }

  void _initErrors(Map<String, Object?> fields, [List<String> path = const []]) {
    final errors = fields['_errors'] as List?;

    if (errors != null) {
      for (final error in errors.cast<Map<String, Object?>>()) {
        final fieldError = FieldError(
          path: path,
          errorCode: error['code'] as String,
          errorMessage: error['message'] as String,
        );

        fieldErrors[fieldError.name] = fieldError;
      }
    }

    for (final nestedElement in fields.entries) {
      if (nestedElement.value is! Map<String, Object?>) {
        continue;
      }

      _initErrors(nestedElement.value as Map<String, Object?>, [...path, nestedElement.key]);
    }
  }
}

/// Information about an error associated with a specific field in a request.
class FieldError {
  /// A human-readable name of this field.
  final String name;

  /// The segments of the path to this field in the request.
  final List<String> path;

  /// The error code.
  final String errorCode;

  /// A human-readable description of the error represented by [errorCode].
  final String errorMessage;

  /// Create a new [FieldError].
  FieldError({
    required this.path,
    required this.errorCode,
    required this.errorMessage,
  }) : name = pathToName(path);

  /// Convert a list of path segments to a human-readable field name.
  ///
  /// For example, the path `[foo, bar, 1, baz]` becomes `foo.bar[1].baz`.
  static String pathToName(List<String> path) {
    if (path.isEmpty) {
      return '';
    }

    final result = StringBuffer(path.first);

    for (final part in path.skip(1)) {
      final isArrayIndex = RegExp(r'^\d+$').hasMatch(part);

      if (isArrayIndex) {
        result.write('[$part]');
      } else {
        result.write('.$part');
      }
    }

    return result.toString();
  }
}
