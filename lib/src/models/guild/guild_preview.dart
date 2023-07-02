import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';

/// {@template guild_preview}
/// A preview of a [Guild].
/// {@endtemplate}
class GuildPreview extends PartialGuild {
  /// The name of the guild.
  final String name;

  /// The hash of the guild's icon.
  final String? iconHash;

  /// The hash of the guild's splash image.
  final String? splashHash;

  /// The hash of the guild's discovery splash image.
  final String? discoverySplashHash;

  /// The emojis in the guild.
  final List<Emoji> emojiList;

  /// The features enabled in the guild.
  final GuildFeatures features;

  /// An approximate number of members in the guild.
  final int approximateMemberCount;

  /// An approximate number of presences in the guild.
  final int approximatePresenceCount;

  /// The guild's description.
  final String? description;

  /// A list of stickers in this guild.
  final List<GuildSticker> stickerList;

  /// {@macro guild_preview}
  GuildPreview({
    required super.id,
    required super.manager,
    required this.name,
    required this.iconHash,
    required this.splashHash,
    required this.discoverySplashHash,
    required this.emojiList,
    required this.features,
    required this.approximateMemberCount,
    required this.approximatePresenceCount,
    required this.description,
    required this.stickerList,
  });
}
