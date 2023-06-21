import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';

class EmojiBuilder implements CreateBuilder<GuildEmoji> {
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
        'image': image.buildDataString(),
        'roles': roles.map((s) => s.toString()).toList(),
      };
}

class EmojiUpdateBuilder implements UpdateBuilder<GuildEmoji> {
  /// The name of the emoji.
  final String? name;

  /// The roles allowed to use this emoji.
  final Iterable<Snowflake>? roles;

  const EmojiUpdateBuilder({
    this.name,
    this.roles,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (roles != null) 'roles': roles!.map((s) => s.toString()).toList(),
      };
}
