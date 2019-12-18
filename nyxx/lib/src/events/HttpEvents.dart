part of nyxx;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpErrorEvent._new(this.response);
}

/// Sent before all HTTP requests are sent. (You can edit them)
///
/// **WARNING:** Once you listen to this stream, all requests
/// will be halted until you call `request.send()`
class BeforeHttpRequestSendEvent {
  /// The request about to be sent.
  HttpBase request;

  BeforeHttpRequestSendEvent._new(this.request);
}

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpResponseEvent._new(this.response);
}
