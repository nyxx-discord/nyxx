part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  MessageChannel? channel;

  /// Id of the channel that the user is typing in.
  late final Snowflake channelId;

  /// The user that is typing.
  User? user;

  /// ID of user that is typing
  late final Snowflake userId;

  /// Timestamp when the user started typing
  late final DateTime timestamp;

  TypingEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channelId = Snowflake(json['d']['channel_id']);
    this.channel = client.channels[channelId] as MessageChannel?;

    this.userId = Snowflake(json['d']['user_id']);
    this.user = client.users[this.userId];

    this.timestamp = DateTime.fromMillisecondsSinceEpoch(json['d']['timestamp'] as int);

    client._events.onTyping.add(this);
  }
}
