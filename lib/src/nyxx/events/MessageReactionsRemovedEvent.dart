part of nyxx;

class MessageReactionsRemovedEvent {
  MessageChannel channel;
  Message message;

  MessageReactionsRemovedEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[new Snowflake(json['d']['channel_id'] as String)] as MessageChannel;
    this.message = channel.getMessage(new Snowflake(json['d']['message_id'] as String));

    client._events.onMessageReactionsRemoved.add(this);
  }
}
