part of nyxx;

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent {
  /// Channel where reactions are removed
  MessageChannel channel;

  /// Message on which messages are removed
  Message message;

  MessageReactionsRemovedEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) => message = msg);

    client._events.onMessageReactionsRemoved.add(this);
  }
}
