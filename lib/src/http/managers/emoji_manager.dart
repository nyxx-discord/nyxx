import 'dart:convert';

import 'package:nyxx/src/builders/emoji/emoji.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/emoji/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

import 'manager.dart';

class ClientEmojiManager {
  final NyxxRest client;

  final Iterable<EmojiManager> _managers;

  Cache<Emoji> get cache => Cache<Emoji>('ClientEmoji', client.options.emojiCacheConfig);

  ClientEmojiManager(this.client, this._managers) {
    for (final manager in _managers) {
      cache.addAll(manager.cache);
    }
  }

  Emoji parse(Map<String, Object?> raw) => _managers.first.parse(raw);

  TextEmoji parseText(Map<String, Object?> raw) => _managers.first.parseText(raw);
}


class EmojiManager extends Manager<Emoji> {

  final Snowflake guildId;

  EmojiManager(super.config, super.client, {required this.guildId});

  @override
  PartialEmoji operator [](Snowflake id) => PartialEmoji(id: id, manager: this);

  @override
  Emoji parse(Map<String, Object?> raw) {
    return Emoji(
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

  TextEmoji parseText(Map<String, Object?> raw) {
    return TextEmoji(
      name: raw['name'] as String,
      manager: this,
    );
  }

  @override
  Future<Emoji> fetch(Snowflake id) async {
    final route = HttpRoute()..guilds(id: guildId.toString())..emojis(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }

  Future<List<Emoji>> fetchAll() async {
    final route = HttpRoute()..guilds(id: guildId.toString())..emojis();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emojis = response.jsonBody as List<Object?>;

    return parseMany(emojis, parse);
  }

  @override
  Future<Emoji> create(EmojiBuilder builder, {String? audiReason}) async {
    final route = HttpRoute()..guilds(id: guildId.toString())..emojis();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditReason}) async {
    final route = HttpRoute()..guilds(id: guildId.toString())..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  @override
  Future<Emoji> update(Snowflake id, EmojiUpdateBuilder builder, {String? auditReason}) async {
    final route = HttpRoute()..guilds(id: guildId.toString())..emojis(id: builder.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>);

    cache[emoji.id] = emoji;
    return emoji;
  }
}
