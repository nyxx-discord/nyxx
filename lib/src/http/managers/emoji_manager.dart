import 'dart:convert';

import 'package:nyxx/src/builders/emoji/emoji.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/emoji/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

import 'manager.dart';

class EmojiManager extends Manager<Emoji> {
  final Snowflake guildId;

  EmojiManager(super.config, super.client, {required this.guildId});

  @override
  PartialEmoji operator [](Snowflake id) => PartialEmoji(id: id, manager: this);

  @override
  Emoji parse(Map<String, Object?> raw) {
    final isUnicode = raw['id'] == null;

    if (isUnicode) {
      return TextEmoji(
        name: raw['name'] as String,
        manager: this,
      );
    } else {
      return GuildEmoji(
        id: Snowflake.parse(raw['id'] as String),
        manager: this,
        user: maybeParse(raw['user'], client.users.parse),
        isAnimated: raw['animated'] as bool?,
        isAvailable: raw['available'] as bool?,
        isManaged: raw['managed'] as bool?,
        requiresColons: raw['require_colons'] as bool?,
        name: raw['name'] as String,
        roles: maybeParseMany(raw['roles'], Snowflake.parse),
      );
    }
  }

  @override
  Future<Emoji> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }

  Future<List<Emoji>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emojis = response.jsonBody as List<Object?>;

    return parseMany(emojis, parse);
  }

  @override
  Future<Emoji> create(EmojiBuilder builder, {String? audiReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }

  @override
  Future<Emoji?> delete(Snowflake id, {String? auditReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    return cache.remove(id);
  }

  @override
  Future<Emoji> update(Snowflake id, EmojiUpdateBuilder builder, {String? auditReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: builder.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }
}
