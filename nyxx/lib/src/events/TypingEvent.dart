part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  MessageChannel? channel;

  /// The user that is typing.
  User? user;

  TypingEvent._new(Map<String, dynamic> json, Nyxx client) {
    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)];
    if (channel == null) return;

    this.channel = channel as MessageChannel;

    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    if (this.user == null) return;

    client._events.onTyping.add(this);
  }
}
