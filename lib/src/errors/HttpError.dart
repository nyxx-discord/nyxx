part of discord;

/// An HTTP error.
class HttpError implements Exception {
  w_transport.Response _r;

  /// The HTTP status code.
  int statusCode;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  String message;

  /// The response body decoded, if it is JSON.
  Map<String, dynamic> json;

  /// The raw response body.
  w_transport.HttpBody body;

  /// Constructs a new [HttpError].
  HttpError._new(this._r) {
    if (_r.headers['content-type'] == "application/json") {
      this.code = _r.body.asJson()['code'];
      this.message = _r.body.asJson()['message'];
    }
    this.body = _r.body;
    this.statusCode = _r.status;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.statusCode.toString() + ": " + _r.statusText;
}
