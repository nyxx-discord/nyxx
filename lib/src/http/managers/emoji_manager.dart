import 'dart:async';
import 'dart:convert';

import 'package:nyxx/src/builders/emoji/emoji.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
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
      id: Snowflake.parse(raw['id'] as String),
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
  FutureOr<GuildEmoji> get(Snowflake id) async => await super.get(id) as GuildEmoji;

  @override
  Future<GuildEmoji> fetch(Snowflake id) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    cache[emoji.id] = emoji;
    return emoji;
  }

  Future<List<GuildEmoji>> list() async {
    _checkIsConcrete();

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final emojis = parseMany(response.jsonBody as List<Object?>, (Map<String, Object?> raw) => parse(raw) as GuildEmoji);

    cache.addEntries(emojis.map((emoji) => MapEntry(emoji.id, emoji)));
    return emojis;
  }

  @override
  Future<GuildEmoji> create(EmojiBuilder builder, {String? audiReason}) async {
    _checkIsConcrete();

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    cache[emoji.id] = emoji;
    return emoji;
  }

  @override
  Future<GuildEmoji> update(Snowflake id, EmojiUpdateBuilder builder, {String? auditReason}) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final emoji = parse(response.jsonBody as Map<String, Object?>) as GuildEmoji;

    cache[emoji.id] = emoji;
    return emoji;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditReason}) async {
    _checkIsConcrete(id);

    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }
}
