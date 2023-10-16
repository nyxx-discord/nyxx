import 'dart:async';

import 'package:nyxx/src/http/managers/sticker_manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/sticker/global_sticker.dart';

/// {@template sticker_pack}
/// A Sticker Pack -- group of stickers that are gated behind Nitro.
/// {@endtemplate}
class StickerPack extends SnowflakeEntity<StickerPack> {
  /// Global sticker manager
  final GlobalStickerManager manager;

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

  /// {@macro sticker_pack}
  StickerPack(
      {required super.id,
      required this.manager,
      required this.stickers,
      required this.name,
      required this.skuId,
      required this.coverStickerId,
      required this.description,
      required this.bannerAssetId});

  @override
  Future<StickerPack> fetch() async => manager.fetchStickerPack(id);

  @override
  Future<StickerPack> get() async => this;
}
