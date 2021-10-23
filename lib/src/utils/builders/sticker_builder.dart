import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

/// Create a new sticker for the guild
class StickerBuilder implements Builder {
  /// Name of the sticker (2-30 characters)
  late String name;

  /// Description of the sticker (empty or 2-100 characters)
  late String description;

  /// The Discord name of a unicode emoji representing the sticker's expression (2-200 characters)
  late String tags;

  /// File that Sticker should be added to sticker
  late final AttachmentBuilder file;

  @override
  RawApiMap build() => {"name": this.name, "description": this.description, "tags": this.tags};
}
