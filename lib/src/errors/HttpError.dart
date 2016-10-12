part of discord;

/// An HTTP error.
class HttpError implements Exception {
  /// The HTTP status code.
  int statusCode;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  int message;

  /// The response body.
  Map<String, dynamic> body;

  /// Constructs a new [HttpError].
  HttpError._new(http.Response r) {
    this.body = JSON.decode(r.body) as Map<String, dynamic>;
    this.statusCode = r.statusCode;
    this.code = body['code'];
    this.message = body['message'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() =>
      this.statusCode.toString() +
      ": " +
      http_utils.ResponseStatus.fromStatusCode(this.statusCode).reason;
}
