part of nyxx;

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages
  List<Snowflake> deletedMessages = List();

  /// Channel on which messages was deleted.
  Channel channel;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json) {
    this.channel =
        client.channels[Snowflake(json['d']['channel_id'] as String)];

    json['d']['ids']
        .forEach((i) => deletedMessages.add(Snowflake(i.toString())));
    client._events.onMessageDeleteBulk.add(this);
  }
}
