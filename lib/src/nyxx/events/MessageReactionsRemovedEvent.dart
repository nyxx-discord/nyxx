part of nyxx;

class MessageReactionsRemovedEvent {
  MessageChannel channel;
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
