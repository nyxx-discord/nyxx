import 'package:nyxx/src/internal/http/http_response.dart';

abstract class IHttpErrorEvent {
  /// The HTTP response.
  HttpResponseError get response;
}

/// Sent when a failed HTTP response is received.
class HttpErrorEvent implements IHttpErrorEvent {
  /// The HTTP response.
  @override
  final HttpResponseError response;

  /// Creates an instance of [HttpErrorEvent]
  HttpErrorEvent(this.response);
}

abstract class IHttpResponseEvent {
  /// The HTTP response.
  HttpResponseSuccess get response;
}

/// Sent when a successful HTTP response is received.
class HttpResponseEvent implements IHttpResponseEvent {
  /// The HTTP response.
  @override
  final HttpResponseSuccess response;

  /// Creates an instance of [HttpResponseEvent]
  HttpResponseEvent(this.response);
}
