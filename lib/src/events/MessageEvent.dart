part of discord;

/// Sent when a new message is received.
class MessageEvent {
  /// The new message.
  Message message;

  MessageEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.message =
          new Message._new(client, json['d'] as Map<String, dynamic>);
      client._events.onMessage.add(this);
    }
  }
}
