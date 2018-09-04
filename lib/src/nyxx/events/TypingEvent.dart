part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  MessageChannel channel;

  /// The user that is typing.
  User user;

  TypingEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;
    this.user = client.users[json['d']['user_id']];
    client._events.onTyping.add(this);
    channel._onTyping.add(this);
  }
}
