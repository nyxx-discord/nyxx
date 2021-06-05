part of nyxx;

/// Message wrapper that other message replies to.
/// [message] field can be null of two reasons: backend error or message was deleted.
/// In first case [isBackendFetchError] will be true and [isDeleted] in second case.
class ReferencedMessage implements Convertable<ReplyBuilder> {
  /// Message object of reply
  late final Message? message;

  /// If true the backend couldn't fetch the message
  late final bool isBackendFetchError;

  /// If true message was deleted
  late final bool isDeleted;

  /// True if references message exists and is available
  bool get exists => !isDeleted && !isBackendFetchError;

  ReferencedMessage._new(INyxx client, Map<String, dynamic> raw) {
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

    this.message = Message._deserialize(client, raw["referenced_message"] as Map<String, dynamic>);
    this.isBackendFetchError = false;
    this.isDeleted = false;
  }

  @override
  ReplyBuilder toBuilder() =>
      ReplyBuilder(this.message?.id ?? Snowflake(0), false);
}
