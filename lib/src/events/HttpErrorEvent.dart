part of discord;

/// Sent when a failed HTTP response is received.
class HttpErrorEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpErrorEvent._new(Client client, this.response) {
    client._events.onHttpError.add(this);
  }
}
