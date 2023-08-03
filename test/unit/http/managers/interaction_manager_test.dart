import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_manager.dart';

final sampleCommandInteraction = {
  "type": 2,
  "token": "A_UNIQUE_TOKEN",
  "member": {
    "user": {"id": "53908232506183680", "username": "Mason", "avatar": "a_d5efa99b3eeaa7dd43acca82f5692432", "discriminator": "1337", "public_flags": 131141},
    "roles": ["539082325061836999"],
    "premium_since": null,
    "permissions": "2147483647",
    "pending": false,
    "nick": null,
    "mute": false,
    "joined_at": "2017-03-13T19:19:14.040000+00:00",
    "is_pending": false,
    "deaf": false,

    // Fields not present in the example but documented
    "flags": 0,
  },
  "id": "786008729715212338",
  "guild_id": "290926798626357999",
  "app_permissions": "442368",
  "guild_locale": "en-US",
  "locale": "en-US",
  "data": {
    "options": [
      {"type": 3, "name": "cardname", "value": "The Gitrog Monster"}
    ],
    "type": 1,
    "name": "cardsearch",
    "id": "771825006014889984"
  },
  "channel_id": "645027906669510667",

  // Fields not present in the example but documented
  "application_id": "0",
  "version": 1,
};

void checkCommandInteraction(Interaction<dynamic> interaction) {
  expect(interaction, isA<ApplicationCommandInteraction>());
  interaction as ApplicationCommandInteraction;

  expect(interaction.id, equals(Snowflake(786008729715212338)));
  expect(interaction.applicationId, equals(Snowflake.zero));
  expect(interaction.type, equals(InteractionType.applicationCommand));
  expect(interaction.guildId, equals(Snowflake(290926798626357999)));
  expect(interaction.channel, isNull);
  expect(interaction.channelId, equals(Snowflake(645027906669510667)));
  expect(interaction.member?.id, equals(Snowflake(53908232506183680)));
  expect(interaction.user, isNull);
  expect(interaction.token, equals('A_UNIQUE_TOKEN'));
  expect(interaction.version, equals(1));
  expect(interaction.message, isNull);
  expect(interaction.appPermissions, equals(Permissions(442368)));
  expect(interaction.locale, equals(Locale.enUs));
  expect(interaction.guildLocale, equals(Locale.enUs));
}

void main() {
  group('InteractionManager', () {
    test('parse', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<InteractionManager, Interaction<dynamic>, Map<String, Object?>>(
        name: 'parse',
        source: sampleCommandInteraction,
        parse: (manager) => manager.parse,
        check: checkCommandInteraction,
      ).runWithManager(InteractionManager(client, applicationId: Snowflake.zero));
    });

    // Endpoints are tested in webhook_manager_test.dart as the implementation is the same.
  });
}
