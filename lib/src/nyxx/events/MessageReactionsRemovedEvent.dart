part of nyxx;

class MessageReactionsRemovedEvent {
  MessageChannel channel;
  Message message;

  MessageReactionsRemovedEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[json['d']['channel_id']] as MessageChannel;
    this.message = channel.getMessage((json['id']['message_id'] as String));

    client._events.onMessageReactionsRemoved.add(this);
  }
}
