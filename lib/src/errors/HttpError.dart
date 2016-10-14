part of discord;

/// An HTTP error.
class HttpError implements Exception {
  /// The HTTP status code.
  int statusCode;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  int message;

  /// The response body decoded, if it is JSON.
  Map<String, dynamic> json;

  /// The raw response body.
  String body;

  /// Constructs a new [HttpError].
  HttpError._new(http.Response r) {
    if (r.headers['content-type'] == "application/json") {
      this.json = JSON.decode(r.body) as Map<String, dynamic>;
      this.code = json['code'];
      this.message = json['message'];
    }
    this.body = r.body;
    this.statusCode = r.statusCode;
  }

  /// Returns a string representation of this object.
  @override
  String toString() =>
      this.statusCode.toString() +
      ": " +
      http_utils.ResponseStatus.fromStatusCode(this.statusCode).reason;
}
