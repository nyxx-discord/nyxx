import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ReactionBuilder {
  final String name;

  final Snowflake? id;

  ReactionBuilder({required this.name, required this.id});

  factory ReactionBuilder.fromEmoji(Emoji emoji) => ReactionBuilder(
        name: emoji.name!,
        id: emoji.id == Snowflake.zero ? null : emoji.id,
      );

  String build() => '$name${id == null ? '' : ':$id'}';
}
