part of nyxx;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpErrorEvent._new(this.response) {
    _client._events.onHttpError.add(this);
  }
}
