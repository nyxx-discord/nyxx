import 'package:nyxx/src/http/managers/sticker_manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/sticker/sticker.dart';
import 'package:nyxx/src/models/user/user.dart';

class PartialGuildSticker extends WritableSnowflakeEntity<GuildSticker> {
  @override
  final GuildStickerManager manager;

  /// @nodoc
  PartialGuildSticker({required super.id, required this.manager});
}

/// {@template guild_sticker}
/// A sticker that can be sent in messages. Represent stickers added to guild
/// {@endtemplate}
class GuildSticker extends PartialGuildSticker with Sticker {
  /// Name of the sticker
  @override
  final String name;

  /// Description of the sticker
  @override
  final String? description;

  /// Autocomplete/suggestion tags for the sticker (comma separated string)
  @override
  final String tags;

  /// Type of sticker
  @override
  final StickerType type;

  /// Type of sticker format
  @override
  final StickerFormatType formatType;

  /// Whether this guild sticker can be used, may be false due to loss of Server Boosts
  @override
  final bool available;

  /// Id of the guild that owns this sticker
  final Snowflake guildId;

  /// The user that uploaded the guild sticker
  @override
  final PartialUser? user;

  /// The standard sticker's sort order within its pack
  @override
  final int? sortValue;

  /// {@macro guild_sticker}
  /// @nodoc
  GuildSticker({
    required super.id,
    required super.manager,
    required this.name,
    required this.description,
    required this.tags,
    required this.type,
    required this.formatType,
    required this.available,
    required this.guildId,
    required this.user,
    required this.sortValue,
  });
}
