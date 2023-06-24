import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';

class StickerCreateBuilder implements CreateBuilder<GuildSticker> {
  /// Name of the sticker (2-30 characters)
  final String name;

  /// Description of the sticker (empty or 2-100 characters)
  final String? description;

  /// Autocomplete/suggestion tags for the sticker (max 200 characters)
  final String tags;

  /// The sticker file to upload
  final ImageBuilder file;

  StickerCreateBuilder({required this.name, required this.description, required this.tags, required this.file});

  @override
  Map<String, Object?> build() => {
        "name": name,
        "description": description ?? '',
        "tags": tags,
      };
}

class StickerUpdateBuilder implements UpdateBuilder<GuildSticker> {
  /// Name of the sticker (2-30 characters)
  final String? name;

  /// Description of the sticker (empty or 2-100 characters)
  final String? description;

  /// Autocomplete/suggestion tags for the sticker (max 200 characters)
  final String? tags;

  StickerUpdateBuilder({this.name, this.description = '', this.tags});

  @override
  Map<String, Object?> build() => {
        if (name != null) "name": name,
        if (description?.isNotEmpty ?? true) "description": description,
        if (tags != null) "tags": tags,
      };
}
