part of nyxx;

abstract class HttpResponse {
  late final int statusCode;
  late final String statusText;

  late final Map<String, String> headers;

  HttpResponse._new(transport.Response response) {
    this.statusCode = response.status;
    this.statusText = response.statusText;
    this.headers = response.headers;
  }
}

class HttpResponseSuccess extends HttpResponse {
  late final transport.HttpBody body;

  dynamic get jsonBody => body.asJson();

  HttpResponseSuccess._new(transport.Response response) : super._new(response) {
    this.body = response.body;
  }
}

class HttpResponseError extends HttpResponse {
  late final String errorMessage;
  late final int errorCode;

  HttpResponseError._new(transport.Response response) : super._new(response) {
    if(response.contentType.type == "application/json") {
      var body = response.body.asJson();

      this.errorCode = body['code'] as int;
      this.errorMessage = body['message'] as String;
    }

    this.errorMessage = response.body.asString();
    this.errorCode = response.status;
  }

  @override
  String toString() {
    return "[Code: $errorCode] [Message: $errorMessage]";
  }
}