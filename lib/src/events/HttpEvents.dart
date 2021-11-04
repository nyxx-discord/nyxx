part of nyxx;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponseError response;

  HttpErrorEvent._new(this.response);
}

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP response.
  HttpResponseSuccess response;

  HttpResponseEvent._new(this.response);
}
