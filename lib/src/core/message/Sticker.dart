import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/IEnum.dart';
import 'package:nyxx/src/utils/builders/StickerBuilder.dart';

/// Base interface for all sticker types
abstract class ISticker implements SnowflakeEntity {
  /// Reference to client
  INyxx get client;

  /// Name of the sticker
  String get name;

  /// Description of the sticker
  String? get description;

  /// Type of sticker
  StickerType get type;

  /// Format of sticker
  StickerFormat get format;

  /// Url for sticker image
  String get stickerURL;
}

/// Base class for all sticker types
abstract class Sticker extends SnowflakeEntity implements ISticker {
  /// Reference to client
  @override
  final INyxx client;

  /// Name of the sticker
  @override
  String get name;

  /// Description of the sticker
  @override
  String? get description;

  /// Type of sticker
  @override
  StickerType get type;

  /// Format of sticker
  @override
  StickerFormat get format;

  /// Url for sticker image
  @override
  String get stickerURL =>
      this.client.httpEndpoints.stickerUrl(this.id, format.getExtension());

  /// Creates an instance of [Sticker]
  Sticker(RawApiMap raw, this.client) : super(Snowflake(raw["id"]));
}

abstract class IPartialSticker implements ISticker {}

/// Partial sticker for message object
class PartialSticker extends Sticker implements IPartialSticker {
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

  /// Creates an instance of [PartialSticker]
  PartialSticker(RawApiMap raw, INyxx client) : super(raw, client);
}

abstract class IGuildSticker implements ISticker {
  /// The Discord name of a unicode emoji representing the sticker's expression.
  String get tags;

  /// Whether this guild sticker can be used, may be false due to loss of Server Boosts
  bool? get available;

  /// Guild that owns this sticker
  Cacheable<Snowflake, IGuild> get guild;

  /// User that uploaded the guild sticker
  IUser? get user;

  /// Edits current sticker
  Future<IGuildSticker> edit(StickerBuilder builder);

  /// Removed current sticker
  Future<void> delete();
}

/// Sticker that is available through guild and nitro users that joined that guild
/// have access to them.
class GuildSticker extends Sticker implements IGuildSticker {
  @override
  late final String name;

  @override
  late final String? description;

  @override
  late final StickerType type;

  @override
  late final StickerFormat format;

  /// The Discord name of a unicode emoji representing the sticker's expression.
  @override
  late final String tags;

  /// Whether this guild sticker can be used, may be false due to loss of Server Boosts
  @override
  late final bool? available;

  /// Guild that owns this sticker
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// User that uploaded the guild sticker
  @override
  late final IUser? user;

  /// Create an instance of [GuildSticker]
  GuildSticker(RawApiMap raw, INyxx client) : super(raw, client) {
    this.name = raw["name"] as String;
    this.description = raw["description"] as String?;
    this.format = StickerFormat.from(raw["format_type"] as int);
    this.type = StickerType.from(raw["type"] as int);

    this.tags = raw["tags"] as String;
    this.available = raw["available"] as bool?;
    this.guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    if (raw["user"] != null) {
      this.user = User(client, raw["user"] as RawApiMap);
    } else {
      this.user = null;
    }
  }

  /// Edits current sticker
  @override
  Future<IGuildSticker> edit(StickerBuilder builder) =>
      client.httpEndpoints.editGuildSticker(this.guild.id, this.id, builder);

  /// Removed current sticker
  @override
  Future<void> delete() =>
      client.httpEndpoints.deleteGuildSticker(this.guild.id, this.id);
}

abstract class IStandardSticker implements ISticker {
  /// Id of the pack the sticker is from
  Snowflake get packId;

  /// Comma-separated list of tags for the sticker.
  /// Available in list form: [tagsList].
  String? get tags;

  /// [StandardSticker] tags in list form
  Iterable<String> get tagsList;
}

/// Animated (or not) image like emoji
class StandardSticker extends Sticker implements IStandardSticker {
  @override
  late final String name;

  @override
  late final String? description;

  @override
  late final StickerType type;

  @override
  late final StickerFormat format;

  /// Id of the pack the sticker is from
  @override
  late final Snowflake packId;

  /// Comma-separated list of tags for the sticker.
  /// Available in list form: [tagsList].
  @override
  late final String? tags;

  /// [StandardSticker] tags in list form
  @override
  Iterable<String> get tagsList => tags!.split(", ").map((e) => e.trim());

  /// Creates an instance of [StandardSticker]
  StandardSticker(RawApiMap raw, INyxx client) : super(raw, client) {
    this.name = raw["name"] as String;
    this.description = raw["description"] as String;
    this.format = StickerFormat.from(raw["format_type"] as int);
    this.type = StickerType.from(raw["type"] as int);

    this.packId = Snowflake(raw["pack_id"]);
    this.tags = raw["tags"] as String;
  }
}

abstract class IStickerPack implements SnowflakeEntity {
  /// The stickers in the pack
  List<StandardSticker> get stickers;

  /// Name of the sticker pack
  String get name;

  /// Id of the pack's SKU
  Snowflake get skuId;

  /// Id of a sticker in the pack which is shown as the pack's icon
  Snowflake get coverStickerId;

  /// Description of the sticker pack
  String get description;

  /// Id of the sticker pack's banner image
  Snowflake get bannerAssetId;
}

/// Represents a pack of standard stickers.
class StickerPack extends SnowflakeEntity implements IStickerPack {
  /// The stickers in the pack
  @override
  late final List<StandardSticker> stickers;

  /// Name of the sticker pack
  @override
  late final String name;

  /// Id of the pack's SKU
  @override
  late final Snowflake skuId;

  /// Id of a sticker in the pack which is shown as the pack's icon
  @override
  late final Snowflake coverStickerId;

  /// Description of the sticker pack
  @override
  late final String description;

  /// Id of the sticker pack's banner image
  @override
  late final Snowflake bannerAssetId;

  /// Creates an instance of [StickerPack]
  StickerPack(RawApiMap raw, INyxx client) : super(Snowflake(raw["id"])) {
    this.stickers = [
      for (final rawSticker in raw["stickers"])
        StandardSticker(rawSticker as RawApiMap, client)
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
  StickerType.from(int value) : super(value);
  const StickerType._create(int value) : super(value);
}

/// Enumerates different possible format of sticker
class StickerFormat extends IEnum<int> {
  static const StickerFormat png = const StickerFormat._create(1);
  static const StickerFormat apng = const StickerFormat._create(2);
  static const StickerFormat lottie = const StickerFormat._create(3);

  /// Creates [StickerFormat] from [value]
  StickerFormat.from(int value) : super(value);
  const StickerFormat._create(int value) : super(value);

  /// Returns extension for given Sticker type
  String getExtension() {
    switch (this.value) {
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
