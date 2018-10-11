part of nyxx;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpErrorEvent._new(this.response) {
    _client._events.onHttpError.add(this);
  }
}

/// Sent before all HTTP requests are sent. (You can edit them)
///
/// **WARNING:** Once you listen to this stream, all requests
/// will be halted until you call `request.send()`
class BeforeHttpRequestSendEvent {
  /// The request about to be sent.
  HttpBase request;

  BeforeHttpRequestSendEvent._new(this.request) {
    if (_client != null) _client._events.beforeHttpRequestSend.add(this);
  }
}

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpResponseEvent._new(this.response) {
    client._events.onHttpResponse.add(this);
  }
}
