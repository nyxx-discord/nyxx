import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/http/managers/emoji_manager.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleGuildEmoji = {
  "id": "41771983429993937",
  "name": "LUL",
  "roles": ["41771983429993000", "41771983429993111"],
  "user": {"username": "Luigi", "discriminator": "0002", "id": "96008815106887111", "avatar": "5500909a3274e1812beb4e8de6631111", "public_flags": 131328},
  "require_colons": true,
  "managed": false,
  "animated": false
};

void checkGuildEmoji(Emoji emoji) {
  expect(emoji, isA<GuildEmoji>());

  emoji as GuildEmoji;
  expect(emoji.id, equals(Snowflake(41771983429993937)));
  expect(emoji.name, equals('LUL'));
  expect(emoji.roleIds, equals([Snowflake(41771983429993000), Snowflake(41771983429993111)]));
  expect(emoji.user?.id, equals(Snowflake(96008815106887111)));
  expect(emoji.requiresColons, isTrue);
  expect(emoji.isManaged, isFalse);
  expect(emoji.isAnimated, isFalse);
  expect(emoji.isAvailable, isNull);
}

final sampleTextEmoji = {"id": null, "name": "🔥"};

void checkTextEmoji(Emoji emoji) {
  expect(emoji, isA<TextEmoji>());

  emoji as TextEmoji;
  expect(emoji.name, equals('🔥'));
}

void main() {
  testManager<Emoji, EmojiManager>(
    'EmojiManager',
    (config, client) => GuildEmojiManager(config, client, guildId: Snowflake(1)),
    RegExp(r'/guilds/1/emojis/\d+'),
    '/guilds/1/emojis',
    sampleObject: sampleGuildEmoji,
    sampleMatches: checkGuildEmoji,
    additionalParsingTests: [
      ParsingTest<EmojiManager, Emoji, Map<String, Object?>>(
        name: 'parse (TextEmoji)',
        source: sampleTextEmoji,
        parse: (manager) => manager.parse,
        check: checkTextEmoji,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<GuildEmojiManager, List<Emoji>, List<Object?>>(
        name: 'list',
        source: [sampleGuildEmoji],
        urlMatcher: '/guilds/1/emojis',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));

          checkGuildEmoji(list.single);
        },
      ),
    ],
    createBuilder: EmojiBuilder(name: 'foo', image: ImageBuilder(data: [], format: 'png'), roles: []),
    updateBuilder: EmojiUpdateBuilder(),
  );
}
