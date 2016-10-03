import 'dart:convert';
import 'package:http/http.dart' as http;

/// An HTTP error.
class HttpError implements Exception {
  /// The HTTP status code.
  int statusCode;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  int message;

  /// Constructs a new [HttpError].
  HttpError(http.Response r) {
    final body = JSON.decode(r.body) as Map<String, dynamic>;
    this.statusCode = r.statusCode;
    this.code = body['code'];
    this.message = body['message'];
  }
}