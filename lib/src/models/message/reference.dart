import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class MessageReference with ToStringHelper {
  final Snowflake? messageId;

  final Snowflake? channelId;

  final Snowflake? guildId;

  MessageReference({
    required this.messageId,
    required this.channelId,
    required this.guildId,
  });
}
