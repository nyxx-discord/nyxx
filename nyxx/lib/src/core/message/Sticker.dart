part of nyxx;

/// Animated (or not) image like emoji
class Sticker extends SnowflakeEntity {
  /// Id of the pack the sticker is from
  late final Snowflake packId;

  /// Name of the sticker
  late final String name;

  /// Description of the sticker
  late final String description;

  /// Comma-separated list of tags for the sticker.
  /// Available in list form: [tagsList].
  late final String? tags;

  /// Sticker asset hash
  late final String asset;

  /// Sticker preview asset hash
  late final String assetPreview;

  /// Type of sticker format
  late final StickerFormat format;

  /// [Sticker] tags in list form
  Iterable<String> get tagsList =>
    this.tags != null
        ? tags!.split(", ").map((e) => e.trim())
        : [];

  Sticker._new(Map<String, dynamic> raw): super(Snowflake(raw["id"])) {
    this.packId = Snowflake(raw["pack_id"]);
    this.name = raw["name"] as String;
    this.description = raw["description"] as String;
    this.tags = raw["tags"] as String?;
    this.asset = raw["asset"] as String;
    this.assetPreview = raw["preview_asset"] as String;
    this.format = StickerFormat.from(raw["format_type"] as int);
  }
}

class StickerFormat extends IEnum<int> {
  static const StickerFormat png = const StickerFormat(1);
  static const StickerFormat apng = StickerFormat(2);
  static const StickerFormat lottie = StickerFormat(3);

  const StickerFormat(int value) : super(value);
  StickerFormat.from(int value): super(value);

  /// Returns extension for given Sticker type
  String getExtension() {
    switch(this.value) {
      case 1:
        return "png";
      case 2:
        return "apng";
      case 3:
        return "tgs";
      default:
        throw ArgumentError("Invalid value for IEnum: `$value`");
    }
  }
}
