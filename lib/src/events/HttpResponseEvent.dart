part of discord;

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP request;
  HttpRequest request;

  /// The HTTP response.
  HttpResponse response;

  HttpResponseEvent._new(Client client, this.request, this.response) {
    client._events.onHttpResponse.add(this);
  }
}
