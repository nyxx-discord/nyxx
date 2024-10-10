import 'dart:convert';

import 'package:nyxx/src/builders/soundboard.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

abstract class SoundboardManager extends Manager<SoundboardSound> {
  SoundboardManager(super.config, super.client, {required super.identifier});

  @override
  SoundboardSound parse(Map<String, Object?> raw) {
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

    Emoji? emoji = maybeParse(raw['emoji_name'], (emoji) => client.guilds[guildId ?? Snowflake.zero].emojis.parse({'id': null, 'name': emoji}));

    emoji ??= client.guilds[guildId ?? Snowflake.zero].emojis.cache[maybeParse(raw['emoji_id'], Snowflake.parse) ?? Snowflake.zero];

    return SoundboardSound(
      id: Snowflake.parse(raw['sound_id']!),
      manager: this,
      name: raw['name'] as String,
      volume: (raw['volume'] as num).toDouble(),
      emoji: emoji,
      emojiName: raw['emoji_name'] as String?,
      emojiId: maybeParse(raw['emoji_id'], Snowflake.parse),
      guildId: guildId,
      isAvailable: raw['available'] as bool,
      user: maybeParse(raw['user'], client.users.parse),
    );
  }

  Future<List<SoundboardSound>> list();
}

/// A [Manager] for guild [SoundboardSound]s
class GuildSoundboardManager extends SoundboardManager {
  /// The guild this manager is for.
  final Snowflake guildId;

  GuildSoundboardManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.soundboard');

  @override
  PartialSoundboardSound operator [](Snowflake id) => PartialSoundboardSound(id: id, manager: this);

  @override
  Future<SoundboardSound> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..soundboardSounds(id: id.toString());

    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);

    final sound = parse(response.jsonBody as Map<String, Object?>);
    client.updateCacheWith(sound);

    return sound;
  }

  @override
  Future<List<SoundboardSound>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..soundboardSounds();

    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);

    final raw = (response.jsonBody as Map<String, Object?>)['items'] as List<Object?>;

    final sounds = parseMany(raw, parse);

    sounds.forEach(client.updateCacheWith);

    return sounds;
  }

  @override
  Future<SoundboardSound> create(SoundboardSoundBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..soundboardSounds();

    final request = BasicRequest(route, method: 'POST', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);

    final soundboard = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(soundboard);

    return soundboard;
  }

  @override
  Future<SoundboardSound> update(Snowflake id, UpdateSoundboardSoundBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..soundboardSounds(id: id.toString());

    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);

    final soundboard = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(soundboard);

    return soundboard;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..soundboardSounds(id: id.toString());

    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  /// Send a soundboard sound to a voice channel the user is connected to. [soundId] is the id of the soundboard sound to play,
  /// while [sourceGuildId] is the id of the guild the soundboard sound is from. (Required to play sounds from different servers.)
  Future<void> sendSoundboardSound(Snowflake channelId, {required Snowflake soundId, Snowflake? sourceGuildId}) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..sendSoundboardSound();

    final request =
        BasicRequest(route, method: 'POST', body: jsonEncode({'sound_id': soundId.toString(), 'source_guild_id': (sourceGuildId ?? guildId).toString()}));

    await client.httpHandler.executeSafe(request);
  }
}

class GlobalSoundboardManager extends SoundboardManager implements ReadOnlyManager<SoundboardSound> {
  GlobalSoundboardManager(super.config, super.client) : super(identifier: 'soundboard');

  @override
  PartialSoundboardSound operator [](Snowflake id) => throw UnsupportedError('Cannot index a global soundboard sound');

  @override
  Future<SoundboardSound> fetch(Snowflake id) async {
    final sounds = await list();

    final sound = sounds.firstWhere(
      (sound) => sound.id == id,
      orElse: () => throw SoundboardSoundNotFoundException(id),
    );

    client.updateCacheWith(sound);
    return sound;
  }

  @override
  Future<List<SoundboardSound>> list() async {
    final route = HttpRoute()..soundboardDefaultSounds();

    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);

    final raw = response.jsonBody as List<Object?>;

    final sounds = parseMany(raw, parse);

    sounds.forEach(client.updateCacheWith);

    return sounds;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) => throw UnsupportedError('Cannot delete a global soundboard sound');

  @override
  Future<SoundboardSound> create(SoundboardSoundBuilder builder, {String? auditLogReason}) => throw UnsupportedError('Cannot create a global soundboard sound');

  @override
  Future<SoundboardSound> update(Snowflake id, UpdateSoundboardSoundBuilder builder, {String? auditLogReason}) =>
      throw UnsupportedError('Cannot update a global soundboard sound');
}
