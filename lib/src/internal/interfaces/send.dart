import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

/// Marks entity to which message can be sent
// ignore: one_member_abstracts
abstract class ISend {
  /// Sends message
  Future<IMessage> sendMessage(MessageBuilder builder);
}
