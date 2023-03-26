import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ForumTagBuilder extends CreateBuilder<ForumTag> {
  final String name;

  final bool? isModerated;

  final Snowflake? emojiId;

  final String? emojiName;

  ForumTagBuilder({required this.name, this.isModerated, this.emojiId, this.emojiName});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (isModerated != null) 'moderated': isModerated,
        if (emojiId != null) 'emoji_id': emojiId!.toString(),
        if (emojiName != null) 'emoji_name': emojiName,
      };
}
