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

/// A text emoji, such as `❤️`.
class TextEmoji extends PartialEmoji {
  static const zeroSnowflake = Snowflake.zero;

  /// The emoji's name.
  final String name;

  TextEmoji({
    required this.name,
    required super.manager,
  }) : super(id: zeroSnowflake);
}

/// A custom guild emoji.
class GuildEmoji extends PartialEmoji {
  /// The emoji's name.
  final String? name;

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
    required this.name,
    required this.roles,
    required this.user,
    required this.requiresColons,
    required this.isManaged,
    required this.isAnimated,
    required this.isAvailable,
  });
}

class Emoji extends PartialEmoji implements TextEmoji, GuildEmoji {
  @override
  final String name;
  
  @override
  final List<Snowflake>? roles;

  @override
  final User? user;

  @override
  final bool? requiresColons;

  @override
  final bool? isManaged;

  @override
  final bool? isAnimated;

  @override
  final bool? isAvailable;

  Emoji({
    required super.id,
    required super.manager,
    required this.name,
    required this.roles,
    required this.user,
    required this.requiresColons,
    required this.isManaged,
    required this.isAnimated,
    required this.isAvailable,
  });

  @override
  String toString() => '<${isAnimated != null && isAnimated! ? 'a' : ''}:$name:$id>';
}
