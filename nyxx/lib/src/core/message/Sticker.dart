part of nyxx;

/// Base interface for all sticker types
abstract class ISticker extends SnowflakeEntity {
  /// Reference to client
  final INyxx client;

  /// Name of the sticker
  String get name;

  /// Description of the sticker
  String? get description;

  /// Type of sticker
  StickerType get type;

  /// Format of sticker
  StickerFormat get format;

  ISticker._new(RawApiMap raw, this.client): super(Snowflake(raw["id"]));

  /// Url for sticker image
  String get stickerURL =>
      this.client.httpEndpoints.stickerUrl(this.id, format.getExtension());
}

/// Partial sticker for message object
class PartialSticker extends ISticker {
  /// Name of sticker
  @override
  late final String name;

  /// Format of the sticker
  @override
  late final StickerFormat format;

  /// Description of the sticker
  @override
  String? get description => null;

  /// Type of sticker
  @override
  StickerType get type => StickerType.partial;

  PartialSticker._new(RawApiMap raw, INyxx client): super._new(raw, client);
}

/// Sticker that is available through guild and nitro users that joined that guild
/// have access to them.
class GuildSticker extends ISticker {
  @override
  late final String name;

  @override
  late final String? description;

  @override
  late final StickerType type;

  @override
  late final StickerFormat format;

  /// The Discord name of a unicode emoji representing the sticker's expression.
  late final String tags;

  /// Whether this guild sticker can be used, may be false due to loss of Server Boosts
  late final bool? available;

  /// Guild that owns this sticker
  late final Cacheable<Snowflake, Guild> guild;

  /// User that uploaded the guild sticker
  late final User? user;

  GuildSticker._new(RawApiMap raw, INyxx client) : super._new(raw, client) {
    this.name = raw["name"] as String;
    this.description = raw["description"] as String?;
    this.format = StickerFormat.from(raw["format_type"] as int);
    this.type = StickerType.from(raw["type"] as int);

    this.tags = raw["tags"] as String;
    this.available = raw["available"] as bool?;
    this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));
    if (raw["user"] != null) {
      this.user = User._new(client, raw["user"] as RawApiMap);
    } else {
      this.user = null;
    }
  }

  /// Edits current sticker
  Future<GuildSticker> edit(StickerBuilder builder) =>
      client.httpEndpoints.editGuildSticker(this.guild.id, this.id, builder);

  /// Removed current sticker
  Future<void> delete() =>
      client.httpEndpoints.deleteGuildSticker(this.guild.id, this.id);
}

/// Animated (or not) image like emoji
class StandardSticker extends ISticker {
  @override
  late final String name;

  @override
  late final String? description;

  @override
  late final StickerType type;

  @override
  late final StickerFormat format;

  /// Id of the pack the sticker is from
  late final Snowflake packId;

  /// Comma-separated list of tags for the sticker.
  /// Available in list form: [tagsList].
  late final String? tags;

  /// [StandardSticker] tags in list form
  Iterable<String> get tagsList => tags!.split(", ").map((e) => e.trim());

  StandardSticker._new(RawApiMap raw, INyxx client): super._new(raw, client) {
    this.name = raw["name"] as String;
    this.description = raw["description"] as String;
    this.format = StickerFormat.from(raw["format_type"] as int);
    this.type = StickerType.from(raw["type"] as int);

    this.packId = Snowflake(raw["pack_id"]);
    this.tags = raw["tags"] as String;
  }
}

/// Represents a pack of standard stickers.
class StickerPack extends SnowflakeEntity {
  /// The stickers in the pack
  late final List<StandardSticker> stickers;

  /// Name of the sticker pack
  late final String name;

  /// Id of the pack's SKU
  late final Snowflake skuId;

  /// Id of a sticker in the pack which is shown as the pack's icon
  late final Snowflake coverStickerId;

  /// Description of the sticker pack
  late final String description;

  /// Id of the sticker pack's banner image
  late final Snowflake bannerAssetId;

  StickerPack._new(RawApiMap raw, INyxx client): super(Snowflake(raw["id"])) {
    this.stickers = [
      for (final rawSticker in raw["stickers"])
        StandardSticker._new(rawSticker as RawApiMap, client)
    ];
    this.name = raw["name"] as String;
    this.skuId = Snowflake(raw["sku_id"]);
    this.coverStickerId = Snowflake(raw["cover_sticker_id"]);
    this.description = raw["description"] as String;
    this.bannerAssetId = Snowflake(raw["banner_asset_id"]);
  }
}

/// Enumerates different possible format of sticker
class StickerType extends IEnum<int> {
  /// Standard nitro sticker
  static const StickerType standard = const StickerType._create(1);

  /// Sticker that was upload to guild, available to nitro users.
  static const StickerType guild = const StickerType._create(2);

  /// Internal nyxx sticker type used in guilds
  static const StickerType partial = const StickerType._create(99);

  /// Creates [StickerType] from [value]
  StickerType.from(int value): super(value);
  const StickerType._create(int value) : super(value);
}

/// Enumerates different possible format of sticker
class StickerFormat extends IEnum<int> {
  static const StickerFormat png = const StickerFormat._create(1);
  static const StickerFormat apng = const StickerFormat._create(2);
  static const StickerFormat lottie = const StickerFormat._create(3);

  /// Creates [StickerFormat] from [value]
  StickerFormat.from(int value): super(value);
  const StickerFormat._create(int value) : super(value);

  /// Returns extension for given Sticker type
  String getExtension() {
    switch(this.value) {
      case 1:
      case 2:
        return "png";
      case 3:
        return "json";
      default:
        throw ArgumentError("Invalid value for IEnum: `$value`");
    }
  }
}
