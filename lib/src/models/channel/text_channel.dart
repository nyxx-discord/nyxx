import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';

abstract class TextChannel implements Channel {
  MessageManager get messages;

  Snowflake? get lastMessageId;

  Duration? get rateLimitPerUser;

  DateTime? get lastPinTimestamp;

  Future<Message> sendMessage(MessageBuilder builder);

  Future<void> triggerTyping();
}
