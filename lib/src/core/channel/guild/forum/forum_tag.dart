import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IForumTag {
  /// Id of forum tag
  Snowflake get id;

  /// Name of forum tag
  String? get name;

  /// Id of corresponding emoji if guild emoji
  Snowflake? get emojiId;

  /// Unicode emoji of emoji if non guild emoji
  String? get emojiName;
}

class ForumTag implements IForumTag {
  @override
  late final Snowflake id;

  @override
  late final String? name;

  @override
  late final Snowflake? emojiId;

  @override
  late final String? emojiName;

  ForumTag(RawApiMap raw) {
    id = Snowflake(raw['id']);
    name = raw['string'] as String?;
    emojiId = raw['emoji_id'] != null ? Snowflake(raw['emoji_id']) : null;
    emojiName = raw['emoji_name'] as String?;
  }
}
