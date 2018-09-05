part of nyxx;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpErrorEvent._new(Nyxx client, this.response) {
    client._events.onHttpError.add(this);
  }
}
