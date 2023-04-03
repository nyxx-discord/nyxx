import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';

abstract class TextChannel implements Channel {
  Snowflake? get lastMessageId;

  Duration? get rateLimitPerUser;

  DateTime? get lastPinTimestamp;
}
