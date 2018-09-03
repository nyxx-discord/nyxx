part of nyxx;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// The updated message, if cached.
  Message newMessage;

  MessageUpdateEvent._new(Client client, Map<String, dynamic> json) {
    var channelId = Snowflake(json['d']['channel_id'] as String);
    var messageId = Snowflake(json['d']['id'] as String);

    if ((client.channels[channelId] as MessageChannel).messages[messageId] != null) {
      this.oldMessage = (client.channels[channelId] as MessageChannel).messages[messageId];
      Map<String, dynamic> data = oldMessage.raw;
      data.addAll(json['d'] as Map<String, dynamic>);
      this.newMessage = Message._new(client, data);
      this.oldMessage._onUpdate.add(this);
      client._events.onMessageUpdate.add(this);
    } else {
      if (!client._options.ignoreUncachedEvents) {
        client._events.onMessageUpdate.add(this);
      }
    }
  }
}
