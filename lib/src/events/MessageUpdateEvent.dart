part of discord;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// The updated message, if cached.
  Message newMessage;

  /// The message's ID.
  String id;

  MessageUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (client.channels[json['d']['channel_id']].messages[json['d']['id']] !=
          null) {
        this.oldMessage =
            client.channels[json['d']['channel_id']].messages[json['d']['id']];
        Map<String, dynamic> data = oldMessage.raw;
        data.addAll(json['d'] as Map<String, dynamic>);
        this.newMessage = new Message._new(client, data);
        this.id = newMessage.id;
        this.oldMessage._onUpdate.add(this);
        client._events.onMessageUpdate.add(this);
      } else {
        this.id = json['d']['id'];
        if (!client._options.ignoreUncachedEvents) {
          client._events.onMessageUpdate.add(this);
        }
      }
    }
  }
}
