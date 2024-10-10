import 'package:mocktail/mocktail.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/builders/sound.dart';
import 'package:nyxx/src/builders/soundboard.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/managers/soundboard_manager.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';
import 'package:test/test.dart';
import '../../../mocks/client.dart';
import '../../../test_manager.dart';

const sampleGlobalSoundboardSound = {
  "name": "quack",
  "sound_id": "1",
  "volume": 1.0,
  "emoji_id": null,
  "emoji_name": "🦆",
  "available": true,
};

const sampleGuildSoundboardSound = {
  "name": "Yay",
  "sound_id": "1106714396018884649",
  "volume": 1,
  "emoji_id": "989193655938064464",
  "emoji_name": null,
  "guild_id": "613425648685547541",
  "available": true
};

void checkGlobalSoundboardSound(SoundboardSound sound, NyxxRest client) {
  expect(sound.id, equals(Snowflake(1)));
  expect(sound.name, equals('quack'));
  expect(sound.volume, equals(1.0));
  expect(sound.emoji, equals(TextEmoji(id: Snowflake.zero, name: '🦆', manager: client.application.emojis)));
  expect(sound.emojiName, equals('🦆'));
  expect(sound.emojiId, isNull);
  expect(sound.guildId, isNull);
  expect(sound.isAvailable, isTrue);
  expect(sound.user, isNull);
}

void checkGuildSoundboardSound(SoundboardSound sound, NyxxRest client) {
  expect(sound.id, equals(Snowflake(1106714396018884649)));
  expect(sound.name, equals('Yay'));
  expect(sound.volume, equals(1.0));
  expect(sound.emoji, equals(client.guilds[Snowflake(613425648685547541)].emojis.cache[Snowflake(989193655938064464)]));
  expect(sound.emojiName, isNull);
  expect(sound.emojiId, equals(Snowflake(989193655938064464)));
  expect(sound.guildId, equals(Snowflake(613425648685547541)));
  expect(sound.isAvailable, isTrue);
  expect(sound.user, isNull);
}

void main() {
  final client = MockNyxx();
  when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
  when(() => client.options).thenReturn(RestClientOptions());
  testReadOnlyManager<SoundboardSound, GlobalSoundboardManager>(
    'GlobalSoundboardManager',
    GlobalSoundboardManager.new,
    '/soundboard-default-sounds',
    sampleObject: sampleGlobalSoundboardSound,
    fetchObjectOverride: [sampleGlobalSoundboardSound],
    sampleMatches: (source) => checkGlobalSoundboardSound(source, client),
    additionalParsingTests: [],
    additionalEndpointTests: [],
  );

  testManager<SoundboardSound, GuildSoundboardManager>(
    'GuildSoundboardManager',
    (config, client) => GuildSoundboardManager(config, client, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/soundboard-sounds/\d+'),
    '/guilds/0/soundboard-sounds',
    sampleObject: sampleGuildSoundboardSound,
    sampleMatches: (sound) => checkGuildSoundboardSound(sound, client),
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<GuildSoundboardManager, void, void>(
          name: 'send-soundboard-sound',
          source: null,
          urlMatcher: '/channels/0/send-soundboard-sound',
          execute: (manager) => manager.sendSoundboardSound(Snowflake.zero, soundId: Snowflake.zero),
          check: (_) {},
          method: 'post'),
    ],
    createBuilder: SoundboardSoundBuilder(
      name: 'cool',
      sound: SoundBuilder.ogg([0, 1, 2, 3]),
      volume: .5,
      emoji: TextEmoji(id: Snowflake.zero, manager: client.application.emojis, name: '😎'),
    ),
    updateBuilder: UpdateSoundboardSoundBuilder(name: 'cooler', volume: .7),
  );
}
