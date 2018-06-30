part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  Channel channel;

  /// The user that is typing.
  User user;

  TypingEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.channel = client.channels[json['d']['channel_id']];
      this.user = client.users[json['d']['user_id']];
      client._events.onTyping.add(this);
    }
  }
}
