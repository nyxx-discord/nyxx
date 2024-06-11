import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';

final class StickerType extends EnumLike<int> {
  static const standard = StickerType._(1);
  static const guild = StickerType._(2);

  static const List<StickerType> values = [standard, guild];

  const StickerType._(super.value);

  factory StickerType.parse(int value) => parseEnum(values, value);
}

final class StickerFormatType extends EnumLike<int> {
  static const png = StickerFormatType._(1);
  static const apng = StickerFormatType._(2);
  static const lottie = StickerFormatType._(3);
  static const gif = StickerFormatType._(4);

  static const List<StickerFormatType> values = [png, apng, lottie, gif];

  const StickerFormatType._(super.value);

  factory StickerFormatType.parse(int value) => parseEnum(values, value);
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
  /// @nodoc
  StickerItem({required super.id, required this.name, required this.formatType});

  @override
  Future<StickerItem> fetch() => get();

  @override
  Future<StickerItem> get() async => this;
}
