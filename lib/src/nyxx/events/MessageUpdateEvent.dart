part of nyxx;

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// Edited message
  Message newMessage;

  MessageUpdateEvent._new( Map<String, dynamic> json) {
    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)] as MessageChannel;
    this.oldMessage = channel.messages[Snowflake(json['d']['id'] as String)];
    this.newMessage = Message._new(json['d'] as Map<String, dynamic>);

    if(oldMessage != null)
      this.oldMessage._onUpdate.add(this);
    client._events.onMessageUpdate.add(this);

    channel._cacheMessage(newMessage);
  }
}
