part of nyxx;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// The updated message, if cached.
  Message newMessage;

  /// The message's ID.
  Snowflake id;

  MessageUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if ((client.channels[new Snowflake(json['d']['channel_id'] as String)] as MessageChannel)
              .messages[new Snowflake(json['d']['id'] as String)] !=
          null) {
        this.oldMessage =
            (client.channels[new Snowflake(json['d']['channel_id'] as String)] as MessageChannel)
                .messages[new Snowflake(json['d']['id'] as String)];
        Map<String, dynamic> data = oldMessage.raw;
        data.addAll(json['d'] as Map<String, dynamic>);
        this.newMessage = new Message._new(client, data);
        this.id = newMessage.id;
        this.oldMessage._onUpdate.add(this);
        client._events.onMessageUpdate.add(this);
      } else {
        this.id = new Snowflake(json['d']['id'] as String);
        if (!client._options.ignoreUncachedEvents) {
          client._events.onMessageUpdate.add(this);
        }
      }
    }
  }
}
