part of nyxx;

/// Marks entity to which message can be sent
// ignore: one_member_abstracts
abstract class ISend {
  /// Sends message
  Future<Message> sendMessage(MessageBuilder builder);
}
