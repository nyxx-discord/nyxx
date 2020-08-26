part of nyxx;

abstract class _HttpResponse {
  late final int statusCode;
  late final Map<String, String> headers;

  late final List<int> _body;
  late final dynamic _jsonBody;
  late final http.ByteStream _bodyStream;

  _HttpResponse._new(http.StreamedResponse response) {
    this._bodyStream = response.stream;
    this.statusCode = response.statusCode;
    this.headers = response.headers;
  }

  Future<void> _finalize() async {
    this._body = await _bodyStream.toBytes();

    if (this._body.isNotEmpty) {
      this._jsonBody = jsonDecode(utf8.decode(this._body));
    }
  }
}

/// Returned when http request is successfully executed.
class HttpResponseSuccess extends _HttpResponse {
  /// Body of response
  List<int> get body => this._body;

  /// Response body as json
  dynamic get jsonBody => this._jsonBody;

  HttpResponseSuccess._new(http.StreamedResponse response) : super._new(response);
}

/// Returned when client fails to execute http request.
/// Will contain reason why request failed.
class HttpResponseError extends _HttpResponse {
  /// Message why http request failed
  late final String errorMessage;

  /// Error code of response
  late final int errorCode;

  HttpResponseError._new(http.StreamedResponse response) : super._new(response) {
    if (response.headers["Content-Type"] == "application/json") {
      this.errorCode = this._jsonBody["code"] as int;
      this.errorMessage = this._jsonBody["message"] as String;
    }

    this.errorMessage = utf8.decode(this._body);
    this.errorCode = response.statusCode;
  }

  @override
  String toString() =>
    "[Code: $errorCode] [Message: $errorMessage]";
}
