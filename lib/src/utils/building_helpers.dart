import 'package:nyxx/nyxx.dart';

Map<String, String> makeEmojiMap({Snowflake? emojiId, String? emojiName}) => {
      if (emojiName case final String emojiName?) 'emoji_name': emojiName,
      if (emojiId case final Snowflake emojiId?) 'emoji_id': emojiId.toString(),
    };
