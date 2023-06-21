import 'package:nyxx/src/http/managers/sticker_manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

enum StickerType {
  standard._(1),
  guild._(2);

  /// The value of this [StickerType].
  final int value;

  const StickerType._(this.value);

  /// Parse a [StickerType] from a [value].
  ///
  /// The [value] must be a valid sticker type
  factory StickerType.parse(int value) => StickerType.values.firstWhere(
        (state) => state.value == value,
        orElse: () => throw FormatException('Unknown sticker type', value),
      );

  @override
  String toString() => 'StickerType($value)';
}

enum StickerFormatType {
  png._(1),
  apng._(2),
  lottie._(3),
  gif._(4);

  /// The value of this [StickerFormatType].
  final int value;

  const StickerFormatType._(this.value);

  /// Parse a [StickerFormatType] from a [value].
  ///
  /// The [value] must be a valid sticker format type
  factory StickerFormatType.parse(int value) => StickerFormatType.values.firstWhere(
        (state) => state.value == value,
        orElse: () => throw FormatException('Unknown sticker format type', value),
      );

  @override
  String toString() => 'StickerFormatType($value)';
}

class PartialSticker extends WritableSnowflakeEntity<Sticker> {
  @override
  final StickerManger manager;

  PartialSticker({required super.id, required this.manager});
}

/// {@template sticker}
/// A sticker that can be sent in messages.
/// {@endtemplate}
class Sticker extends PartialSticker {
  final String? packId;

  final String name;

  final String? description;

  final String tags;

  final StickerType type;

  final StickerFormatType formatType;

  final bool available;

  final Snowflake? guildId;

  final PartialUser? user;

  final int? sortValue;

  /// {@macro application}
  Sticker(
      {required super.id,
      required super.manager,
      required this.packId,
      required this.name,
      required this.description,
      required this.tags,
      required this.type,
      required this.formatType,
      required this.available,
      required this.guildId,
      required this.user,
      required this.sortValue});

  /// Returns tags in list format since [tags] field is comma-separated string
  List<String> getTags() => tags.split(',');
}
