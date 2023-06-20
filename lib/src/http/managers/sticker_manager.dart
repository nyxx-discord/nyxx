import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/sticker/sticker.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class StickerManger extends Manager<Sticker> {
  final Snowflake? guildId;

  StickerManger(super.config, super.client, {required this.guildId}) : super(identifier: guildId != null ? "$guildId.stickers" : "stickers");

  @override
  WritableSnowflakeEntity<Sticker> operator [](Snowflake id) => PartialSticker(id: id, manager: this);

  @override
  Future<Sticker> create(covariant CreateBuilder<Sticker> builder) {
    // TODO: implement update
    throw UnimplementedError();
  }

  Future<List<Sticker>> list() async {
    _checkForGuild();

    final route = HttpRoute()
      ..guilds(id: guildId!.toString())
      ..stickers();

    final request = BasicRequest(route);
    final response = await client.httpHandler.executeSafe(request);

    final stickers = parseMany(response.jsonBody as List<Object?>, (Map<String, Object?> raw) => parse(raw));
    cache.addEntries(stickers.map((sticker) => MapEntry(sticker.id, sticker)));

    return stickers;
  }

  @override
  Future<void> delete(Snowflake id) async {
    _checkForGuild();

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  @override
  Future<Sticker> fetch(Snowflake id) async {
    _checkForGuild();

    final route = HttpRoute()
      ..guilds(id: guildId!.toString())
      ..stickers(id: id.toString());

    final request = BasicRequest(route);
    final response = await client.httpHandler.executeSafe(request);

    final sticker = parse(response.jsonBody as Map<String, Object?>);

    cache[sticker.id] = sticker;
    return sticker;
  }

  @override
  Sticker parse(Map<String, Object?> raw) {
    return Sticker(
      manager: this,
      id: Snowflake.parse(raw['id'] as String),
      packId: raw['pack_id'] as String?,
      name: raw['name'] as String,
      description: raw['description'] as String,
      tags: raw['tags'] as String,
      type: StickerType.parse(raw['type'] as int),
      formatType: StickerFormatType.parse(raw['format_type'] as int),
      available: raw['available'] as bool? ?? false,
      guildId: raw['guild_id'] != null ? Snowflake.parse(raw['guild_id'] as String) : null,
      user: ((raw['user'] ?? {}) as Map)['id'] != null ? client.users[Snowflake.parse((raw['user'] as Map)['id'] as String)] : null,
      sortValue: raw['sort_value'] as int?,
    );
  }

  @override
  Future<Sticker> update(Snowflake id, covariant UpdateBuilder<Sticker> builder) {
    // TODO: implement update
    throw UnimplementedError();
  }

  void _checkForGuild() {
    if (guildId == null) {
      throw UnsupportedError("Cannot perform this operation on global sticker");
    }
  }
}
