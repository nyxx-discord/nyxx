part of nyxx;

abstract class _HttpResponse {
  late final int statusCode;
  late final String statusText;

  late final Map<String, String> headers;

  _HttpResponse._new(transport.Response response) {
    this.statusCode = response.status;
    this.statusText = response.statusText;
    this.headers = response.headers;
  }
}

/// Returned when http request is successfully executed.
class HttpResponseSuccess extends _HttpResponse {
  /// Body of response
  late final transport.HttpBody body;

  /// Response body as json
  dynamic get jsonBody => body.asJson();

  HttpResponseSuccess._new(transport.Response response) : super._new(response) {
    this.body = response.body;
  }
}

/// Returned when client fails to execute http request.
/// Will contain reason why request failed.
class HttpResponseError extends _HttpResponse {
  /// Message why http request failed
  late final String errorMessage;

  /// Error code of response
  late final int errorCode;

  HttpResponseError._new(transport.Response response) : super._new(response) {
    if (response.contentType.type == "application/json") {
      final body = response.body.asJson();

      this.errorCode = body["code"] as int;
      this.errorMessage = body["message"] as String;
    }

    this.errorMessage = response.body.asString();
    this.errorCode = response.status;
  }

  @override
  String toString() =>
    "[Code: $errorCode] [Message: $errorMessage]";
}
