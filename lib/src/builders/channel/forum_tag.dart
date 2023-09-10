import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/snowflake.dart';

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
        if (emojiId != null) 'emoji_id': emojiId!.toString(),
        if (emojiName != null) 'emoji_name': emojiName,
      };
}
