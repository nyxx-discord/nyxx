import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/emoji/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';

class EmojiBuilder implements CreateBuilder<Emoji> {
  /// The name of the emoji.
  final String name;

  /// The 128x128 emoji image.
  final ImageBuilder image;

  /// The roles allowed to use this emoji.
  final Iterable<Snowflake> roles;

  const EmojiBuilder({
    required this.name,
    required this.image,
    required this.roles,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        'image': image.build(),
        'roles': roles.toList(),
      };
}

class EmojiUpdateBuilder implements UpdateBuilder<Emoji> {
  /// The name of the emoji.
  final String name;

  /// The roles allowed to use this emoji.
  final Iterable<Snowflake>? roles;

  const EmojiUpdateBuilder({
    required this.name,
    required this.roles,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (roles != null) 'roles': roles!.toList(),
      };
}
