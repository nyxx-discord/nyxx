part of nyxx;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// Raw event data
  dynamic newMessage;

  MessageUpdateEvent._new( Map<String, dynamic> json) {
    var channelId = Snowflake(json['d']['channel_id'] as String);
    var messageId = Snowflake(json['d']['id'] as String);

    if ((client.channels[channelId] as MessageChannel).messages[messageId] !=
        null) {
      this.oldMessage =
          (client.channels[channelId] as MessageChannel).messages[messageId];
      this.newMessage = json['d'];
      this.oldMessage._onUpdate.add(this);
      client._events.onMessageUpdate.add(this);
    } else {
      if (!client._options.ignoreUncachedEvents) {
        client._events.onMessageUpdate.add(this);
      }
    }
  }
}
