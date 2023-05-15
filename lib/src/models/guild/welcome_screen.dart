import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class WelcomeScreen with ToStringHelper {
  final String? description;

  final List<WelcomeScreenChannel> channels;

  WelcomeScreen({required this.description, required this.channels});
}

class WelcomeScreenChannel with ToStringHelper {
  final Snowflake channelId;

  final String description;

  final Snowflake? emojiId;

  final String? emojiName;

  WelcomeScreenChannel({
    required this.channelId,
    required this.description,
    required this.emojiId,
    required this.emojiName,
  });
}
