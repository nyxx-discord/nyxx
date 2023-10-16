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

/// Mixin with shared properties with stickers
mixin Sticker {
  /// Name of the sticker
  String get name;

  /// Description of the sticker
  String? get description;

  /// Autocomplete/suggestion tags for the sticker (comma separated string)
  String get tags;

  /// Type of sticker
  StickerType get type;

  /// Type of sticker format
  StickerFormatType get formatType;

  /// Whether this guild sticker can be used, may be false due to loss of Server Boosts
  bool get available;

  /// The user that uploaded the guild sticker
  PartialUser? get user;

  /// The standard sticker's sort order within its pack
  int? get sortValue;

  /// Returns tags in list format since [tags] field is comma-separated string
  List<String> getTags() => tags.split(',');
}

/// {@template sticker_item}
/// A representation of a sticker with minimal information
/// {@endtemplate}
class StickerItem extends SnowflakeEntity<StickerItem> {
  /// Name of sticker
  final String name;

  /// Format type of sticker
  final StickerFormatType formatType;

  /// {@macro sticker_item}
  StickerItem({required super.id, required this.name, required this.formatType});

  @override
  Future<StickerItem> fetch() => get();

  @override
  Future<StickerItem> get() async => this;
}
