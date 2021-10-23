import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/reply_builder.dart';

abstract class IReferencedMessage implements Convertable<ReplyBuilder> {
  /// Message object of reply
  IMessage? get message;

  /// If true the backend couldn't fetch the message
  bool get isBackendFetchError;

  /// If true message was deleted
  bool get isDeleted;

  /// True if references message exists and is available
  bool get exists;
}

/// Message wrapper that other message replies to.
/// [message] field can be null of two reasons: backend error or message was deleted.
/// In first case [isBackendFetchError] will be true and [isDeleted] in second case.
class ReferencedMessage implements IReferencedMessage {
  /// Message object of reply
  @override
  late final IMessage? message;

  /// If true the backend couldn't fetch the message
  @override
  late final bool isBackendFetchError;

  /// If true message was deleted
  @override
  late final bool isDeleted;

  /// True if references message exists and is available
  @override
  bool get exists => !isDeleted && !isBackendFetchError;

  ReferencedMessage(INyxx client, RawApiMap raw) {
    if (!raw.containsKey("referenced_message")) {
      this.message = null;
      this.isBackendFetchError = true;
      this.isDeleted = false;
      return;
    }

    if (raw["referenced_message"] == null) {
      this.message = null;
      this.isBackendFetchError = false;
      this.isDeleted = true;
      return;
    }

    this.message = Message(client, raw["referenced_message"] as RawApiMap);
    this.isBackendFetchError = false;
    this.isDeleted = false;
  }

  @override
  ReplyBuilder toBuilder() => ReplyBuilder(this.message?.id ?? Snowflake(0), false);
}
