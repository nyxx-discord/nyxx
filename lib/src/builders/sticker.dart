import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';

class StickerBuilder implements CreateBuilder<GuildSticker> {
  /// Name of the sticker (2-30 characters)
  String name;

  /// Description of the sticker (empty or 2-100 characters)
  String description;

  /// Autocomplete/suggestion tags for the sticker (max 200 characters)
  String tags;

  /// The sticker file to upload
  ImageBuilder file;

  StickerBuilder({required this.name, this.description = '', required this.tags, required this.file});

  @override
  Map<String, String> build() => {
        "name": name,
        "description": description,
        "tags": tags,
      };
}

class StickerUpdateBuilder implements UpdateBuilder<GuildSticker> {
  /// Name of the sticker (2-30 characters)
  String? name;

  /// Description of the sticker (empty or 2-100 characters)
  String? description;

  /// Autocomplete/suggestion tags for the sticker (max 200 characters)
  String? tags;

  StickerUpdateBuilder({this.name, this.description = sentinelString, this.tags});

  @override
  Map<String, Object?> build() => {
        if (!identical(description, sentinelString)) "description": description ?? '',
        if (name != null) "name": name,
        if (tags != null) "tags": tags,
      };
}
