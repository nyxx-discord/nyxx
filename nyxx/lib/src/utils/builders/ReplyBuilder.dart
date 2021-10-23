import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/Builder.dart';

/// Builder for replying to message
class ReplyBuilder extends Builder {
  /// Id of message you reply to
  final Snowflake messageId;

  /// True if reply should fail if target message does not exist
  final bool failIfNotExists;

  /// Constructs reply builder for given message in channel
  ReplyBuilder(this.messageId, [this.failIfNotExists = true]);

  /// Constructs message reply from given message
  factory ReplyBuilder.fromMessage(IMessage message, [bool failIfNotExists = true]) =>
      ReplyBuilder(message.id, failIfNotExists);

  /// Constructs message reply from cacheable of message and channel
  factory ReplyBuilder.fromCacheable(Cacheable<Snowflake, IMessage> messageCacheable, [bool failIfNotExists = true]) =>
    ReplyBuilder(messageCacheable.id, failIfNotExists);

  @override
  RawApiMap build() => {
    "message_id": this.messageId.id,
    "fail_if_not_exists": this.failIfNotExists
  };
}
