part of nyxx;

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
