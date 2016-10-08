part of discord;

/// Sent when the client is ready.
class ReadyEvent {
  /// Sends a new ready event.
  ReadyEvent(Client client) {
    client._events.onReady.add(this);
  }
}
