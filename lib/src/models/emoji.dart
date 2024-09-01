import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/emoji_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

/// A partial [Emoji] object.
class PartialEmoji extends WritableSnowflakeEntity<Emoji> {
  @override
  final EmojiManager manager;

  /// Create a new [PartialEmoji].
  /// @nodoc
  PartialEmoji({required super.id, required this.manager});
}

/// An emoji. Either a [TextEmoji], an [ApplicationEmoji] or a [GuildEmoji].
abstract class Emoji extends PartialEmoji {
  /// The emoji's name. Can be `dartlang` for a custom emoji, or `❤️` for a text emoji.
  String? get name;

  /// @nodoc
  Emoji({
    required super.id,
    required super.manager,
  });
}

/// A text emoji, such as `❤️`.
class TextEmoji extends Emoji {
  @override
  final String name;

  /// @nodoc
  TextEmoji({
    required super.id,
    required super.manager,
    required this.name,
  });

  // Intercept fetch since the manager will throw if we attempt to fetch a text emoji
  @override
  Future<TextEmoji> fetch() async => this;
}

// TODO(lexedia): Rename GuildEmoji to ApplicationEmoji?
// typedef ApplicationEmoji = GuildEmoji;

// Apparently an ApplicationEmoji contains a `roles` field, but it's always an empty list.
class ApplicationEmoji extends Emoji {
  @override
  final String name;

  /// The user that created this emoji. `null` if it was the first time it was created.
  final User? user;

  /// Whether this emoji must be wrapped in colons.
  final bool requiresColons;

  /// Whether this emoji is managed.
  final bool isManaged;

  /// Whether this emoji is animated.
  final bool isAnimated;

  /// Whether this emoji can be used, always true for ApplicationEmojis.
  final bool isAvailable;

  /// @nodoc
  ApplicationEmoji({
    required super.id,
    required ApplicationEmojiManager super.manager,
    required this.name,
    required this.user,
    required this.requiresColons,
    required this.isManaged,
    required this.isAnimated,
    required this.isAvailable,
  });

  /// This emoji's image.
  CdnAsset get image => CdnAsset(
        client: manager.client,
        base: HttpRoute()..emojis(),
        hash: id.toString(),
        isAnimated: isAnimated,
      );
}


/// A custom guild emoji.
class GuildEmoji extends Emoji {
  @override
  final String? name;

  /// Id of roles allowed to use this emoji.
  final List<Snowflake>? roleIds;

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

  /// @nodoc
  GuildEmoji({
    required super.id,
    required GuildEmojiManager super.manager,
    required this.name,
    required this.roleIds,
    required this.user,
    required this.requiresColons,
    required this.isManaged,
    required this.isAnimated,
    required this.isAvailable,
  });

  /// The roles allowed to use this emoji.
  List<PartialRole>? get roles => roleIds?.map((e) => manager.client.guilds[(manager as GuildEmojiManager).guildId].roles[e]).toList();

  /// This emoji's image.
  CdnAsset get image => CdnAsset(
        client: manager.client,
        base: HttpRoute()..emojis(),
        hash: id.toString(),
        isAnimated: isAnimated,
      );
}
