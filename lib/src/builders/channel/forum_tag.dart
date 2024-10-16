import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/building_helpers.dart';

class ForumTagBuilder extends CreateBuilder<ForumTag> {
  String name;

  bool? isModerated;

  Snowflake? emojiId;

  String? emojiName;

  ForumTagBuilder({required this.name, this.isModerated, this.emojiId, this.emojiName});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (isModerated != null) 'moderated': isModerated,
        ...makeEmojiMap(emojiId: emojiId, emojiName: emojiName),
      };
}
