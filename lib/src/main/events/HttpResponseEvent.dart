part of discord;

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpResponseEvent._new(Client client, this.response) {
    client._events.onHttpResponse.add(this);
  }
}
