import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';

class EmojiBuilder implements CreateBuilder<GuildEmoji> {
  /// The name of the emoji.
  String name;

  /// The 128x128 emoji image.
  ImageBuilder image;

  /// The roles allowed to use this emoji.
  Iterable<Snowflake> roles;

  EmojiBuilder({
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
  String? name;

  /// The roles allowed to use this emoji.
  Iterable<Snowflake>? roles;

  EmojiUpdateBuilder({
    this.name,
    this.roles = sentinelList,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(roles, sentinelList)) 'roles': roles?.map((s) => s.toString()).toList(),
      };
}

class ApplicationEmojiBuilder implements CreateBuilder<ApplicationEmoji> {
  /// The name of the emoji.
  String name;

  /// The 128x128 emoji image.
  ImageBuilder image;

  ApplicationEmojiBuilder({
    required this.name,
    required this.image,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        'image': image.buildDataString(),
      };
}

class ApplicationEmojiUpdateBuilder implements UpdateBuilder<ApplicationEmoji> {
  /// The name of the emoji.
  String? name;

  ApplicationEmojiUpdateBuilder({
    this.name,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
      };
}
