part of nyxx;

/// Sent when a successful HTTP response is received.
class HttpResponseEvent {
  /// The HTTP response.
  HttpResponse response;

  HttpResponseEvent._new( this.response) {
    client._events.onHttpResponse.add(this);
  }
}
