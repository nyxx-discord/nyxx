part of nyxx;

/// An HTTP error.
class HttpError implements Exception {
  /// The full http response.
  HttpResponse response;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  String message;

  /// Constructs a new [HttpError].
  HttpError._new(this.response) {
    //if (response.headers['content-type'] == "application/json") {
      //this.code = response.body['code'] as int;
      //this.message = response.body.asJson()['message'] as String;
    //}
  }

  /// Returns a string representation of this object.
  @override
  String toString() => response.status.toString() + ": " + response.statusText;
}
