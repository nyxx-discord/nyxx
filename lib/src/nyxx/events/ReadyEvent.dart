part of nyxx;

/// Sent when the client is ready.
class ReadyEvent {
  ReadyEvent._new() {
    client.ready = true;
  }
}
