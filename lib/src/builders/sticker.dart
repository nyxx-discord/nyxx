import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/sticker/sticker.dart';

class StickerCreateBuilder implements CreateBuilder<Sticker> {
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
