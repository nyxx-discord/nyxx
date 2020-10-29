part of nyxx;

/// Builder for replying to message
class ReplyBuilder implements Builder {
  /// Id of message you reply to
  final Snowflake messageId;

  /// Id of channel of message which you reply to
  final Snowflake channelId;

  /// Constructs reply builder for given message in channel
  ReplyBuilder(this.messageId, this.channelId);

  /// Constructs message reply from given message
  factory ReplyBuilder.froMessage(Message message) =>
      ReplyBuilder(message.id, message.channel.id);

  /// Constructs message reply from cacheable of message and channel
  factory ReplyBuilder.fromCacheable(Cacheable<Snowflake, Message> messageCacheable, Cacheable<Snowflake, TextChannel> channelCacheable) =>
    ReplyBuilder(messageCacheable.id, channelCacheable.id);

  @override
  Map<String, dynamic> _build() => {
    "message_id": this.messageId.id,
    "channel_id": this.channelId.id
  };
}
