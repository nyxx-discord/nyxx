part of discord;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The updated message, if cached.
  Message message;

  MessageUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.message =
          new Message._new(client, json['d'] as Map<String, dynamic>);
      client._events.onMessageUpdate.add(this);
    }
  }
}
