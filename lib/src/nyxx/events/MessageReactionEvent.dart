part of nyxx;

class MessageReactionEvent {
  /// User who fired event
  User user;

  /// Channel on which event was fired
  MessageChannel channel;

  /// Message to which emoji was added
  Message message;

  /// Emoji object.
  Emoji emoji;

  MessageReactionEvent._new(Map<String, dynamic> json, bool remove) {
    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) {
      message = msg;

      if (json['d']['emoji']['id'] == null)
        emoji = UnicodeEmoji((json['d']['emoji']['name'] as String));
      else
        emoji = GuildEmoji._partial(json['d']['emoji'] as Map<String, dynamic>);

      if (remove) {
        this.message._onReactionRemove.add(this);
        client._events.onMessageReactionRemove.add(this);
      } else {
        this.message._onReactionAdded.add(this);
        client._events.onMessageReactionAdded.add(this);
      }
    });
  }
}
