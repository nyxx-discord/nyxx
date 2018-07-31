part of nyxx;

/// Sent when a message is deleted.
class MessageDeleteEvent {
  /// The message, if cached.
  Message message;

  /// The ID of the message.
  Snowflake id;

  MessageDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if ((client.channels[json['d']['channel_id']] as MessageChannel)
              .messages[json['d']['id']] !=
          null) {
        this.message =
            (client.channels[json['d']['channel_id']] as MessageChannel)
                .messages[json['d']['id']];
        this.id = message.id;
        this.message._onDelete.add(this);
        client._events.onMessageDelete.add(this);
      } else {
        this.id = new Snowflake(json['d']['id']);
        if (!client._options.ignoreUncachedEvents) {
          client._events.onMessageDelete.add(this);
        }
      }
    }
  }
}
