import 'dart:async';

import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/sticker/global_sticker.dart';

class StickerPack extends SnowflakeEntity<StickerPack> {
  /// The stickers in the pack
  final List<GlobalSticker> stickers;

  /// Name of the sticker pack
  final String name;

  /// Id of the pack's SKU
  final Snowflake skuId;

  /// Id of a sticker in the pack which is shown as the pack's icon
  final Snowflake? coverStickerId;

  /// Description of the sticker pack
  final String description;

  /// Id of the sticker pack's banner image
  final Snowflake? bannerAssetId;

  StickerPack(
      {required super.id,
      required this.stickers,
      required this.name,
      required this.skuId,
      required this.coverStickerId,
      required this.description,
      required this.bannerAssetId});

  @override
  Future<StickerPack> fetch() async => get();

  @override
  FutureOr<StickerPack> get() => this;
}