part of nyxx;

/// Sent when the client is ready.
class ReadyEvent {
  ReadyEvent._new(Nyxx client) {
    client.ready = true;
    client._events.onReady.add(this);
  }
}
