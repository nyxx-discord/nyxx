part of nyxx;

/// Builder for replying to message
class ReplyBuilder extends Builder {
  /// Id of message you reply to
  final Snowflake messageId;

  /// Constructs reply builder for given message in channel
  ReplyBuilder(this.messageId);

  /// Constructs message reply from given message
  factory ReplyBuilder.fromMessage(Message message) =>
      ReplyBuilder(message.id);

  /// Constructs message reply from cacheable of message and channel
  factory ReplyBuilder.fromCacheable(Cacheable<Snowflake, Message> messageCacheable) =>
    ReplyBuilder(messageCacheable.id);

  @override
  Map<String, dynamic> build() => {
    "message_id": this.messageId.id
  };
}
