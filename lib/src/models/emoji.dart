import 'dart:async';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/emoji_manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

/// A partial [Emoji] object.
class PartialEmoji extends WritableSnowflakeEntity<Emoji> {
  @override
  final EmojiManager manager;

  /// Create a new [PartialEmoji].
  PartialEmoji({required super.id, required this.manager});
}

/// An emoji. Either a [TextEmoji] or a [GuildEmoji].
class Emoji extends PartialEmoji {
  /// The emoji's name. Can be `dartlang` for a custom emoji, or `❤️` for a text emoji.
  final String? name;

  Emoji({
    required super.id,
    required super.manager,
    required this.name,
  });
}

/// A text emoji, such as `❤️`.
class TextEmoji implements Emoji {
  @override
  final String name;

  @override
  final EmojiManager manager;

  @override
  final Snowflake id = Snowflake.zero;

  TextEmoji({
    required this.name,
    required this.manager,
  });

  @override
  Future<Emoji> fetch() => throw UnsupportedError('Cannot fetch a text emoji.');

  @override
  String defaultToString() => name;

  @override
  Future<void> delete() => throw UnsupportedError('Cannot delete a text emoji.');

  @override
  FutureOr<Emoji> get() => this;

  @override
  Future<Emoji> update(covariant UpdateBuilder<Emoji> builder) => throw UnsupportedError('Cannot update a text emoji.');
}

/// A custom guild emoji.
class GuildEmoji extends Emoji {
  // Id of roles allowed to use this emoji.
  final List<Snowflake>? roles;

  /// The user that created this emoji.
  final User? user;

  /// Whether this emoji must be wrapped in colons.
  final bool? requiresColons;

  /// Whether this emoji is managed.
  final bool? isManaged;

  /// Whether this emoji is animated.
  final bool? isAnimated;

  /// Whether this emoji can be used, may be false due to loss of Server Boosts.
  final bool? isAvailable;

  GuildEmoji({
    required super.id,
    required super.manager,
    required super.name,
    required this.roles,
    required this.user,
    required this.requiresColons,
    required this.isManaged,
    required this.isAnimated,
    required this.isAvailable,
  });

  @override
  String defaultToString() => '<${isAnimated == true ? 'a' : ''}:$name:$id>';
}
