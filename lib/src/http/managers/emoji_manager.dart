import 'dart:async';
import 'dart:convert';

import 'package:nyxx/src/builders/emoji/emoji.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

import 'manager.dart';

class EmojiManager extends Manager<Emoji> {
  final Snowflake guildId;

  EmojiManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.emojis');

  @override
  PartialEmoji operator [](Snowflake id) => PartialEmoji(id: id, manager: this);

  @override
  Emoji parse(Map<String, Object?> raw) {
    final isUnicode = raw['id'] == null;

    if (isUnicode) {
      return TextEmoji(
        name: raw['name'] as String,
        manager: this,
        id: Snowflake.zero,
      );
    }

    return GuildEmoji(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      user: maybeParse(raw['user'], client.users.parse),
      isAnimated: raw['animated'] as bool?,
      isAvailable: raw['available'] as bool?,
      isManaged: raw['managed'] as bool?,
      requiresColons: raw['require_colons'] as bool?,
      name: raw['name'] as String?,
      roleIds: maybeParseMany(raw['roles'], Snowflake.parse),
    );
  }

  void _checkIsConcrete([Snowflake? id]) {
    if (guildId == Snowflake.zero) {
      throw UnsupportedError('Cannot fetch, create, update or delete emoji received without a guild');
    }

    if (id == Snowflake.zero) {
      throw UnsupportedError('Cannot fetch, create, update or delete a text emoji by ID');
    }
  }

  @override
  Future<GuildEmoji> get(Snowflake id) async => await super.get(id) as GuildEmoji;

  /// Fetch a emoji.
  @override
  Future<GuildEmoji> fetch(Snowflake id) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    client.updateCacheWith(emoji);
    return emoji;
  }

  /// List the emojis in the guild.
  Future<List<GuildEmoji>> list() async {
    _checkIsConcrete();

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emojis = parseMany(response.jsonBody as List<Object?>, (Map<String, Object?> raw) => parse(raw) as GuildEmoji);

    emojis.forEach(client.updateCacheWith);
    return emojis;
  }

  @override
  Future<GuildEmoji> create(EmojiBuilder builder, {String? auditLogReason}) async {
    _checkIsConcrete();

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()), auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    client.updateCacheWith(emoji);
    return emoji;
  }

  /// Update a emoji using the provided [builder].
  @override
  Future<GuildEmoji> update(Snowflake id, EmojiUpdateBuilder builder, {String? auditLogReason}) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()), auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    client.updateCacheWith(emoji);
    return emoji;
  }

  /// Delete a emoji.
  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }
}
