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
  "entitlements": [],

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
  expect(interaction.entitlements, equals([]));
}

final sampleCommandInteraction2 = {
  "version": 1,
  "type": 2,
  "token": "REDACTED",
  "member": {
    "user": {
      "username": "abitofevrything",
      "public_flags": 128,
      "id": "506759329068613643",
      "global_name": "Abitofevrything",
      "discriminator": "0",
      "avatar_decoration_data": null,
      "avatar": "b591ea8a9d057669ea2a6cd3ab450301"
    },
    "unusual_dm_activity_until": null,
    "roles": ["1034762811726901269"],
    "premium_since": null,
    "permissions": "562949953421311",
    "pending": false,
    "nick": null,
    "mute": false,
    "joined_at": "2022-10-23T10:03:13.019000+00:00",
    "flags": 2,
    "deaf": false,
    "communication_disabled_until": null,
    "avatar": null
  },
  "locale": "en-GB",
  "id": "1145002345244135444",
  "guild_locale": "en-US",
  "guild_id": "1033681997136146462",
  "guild": {
    "locale": "en-US",
    "id": "1033681997136146462",
    "features": ["GUILD_ONBOARDING_EVER_ENABLED", "GUILD_ONBOARDING_HAS_PROMPTS", "NEWS", "GUILD_ONBOARDING", "COMMUNITY"]
  },
  "entitlements": [],
  "entitlement_sku_ids": [],
  "data": {
    "type": 1,
    "resolved": {
      "users": {
        "1033681843708510238": {
          "username": "Abitofbot",
          "public_flags": 0,
          "id": "1033681843708510238",
          "global_name": null,
          "discriminator": "8969",
          "bot": true,
          "avatar_decoration_data": null,
          "avatar": null
        }
      },
      "members": {
        "1033681843708510238": {
          "unusual_dm_activity_until": null,
          "roles": ["1123231366734168107"],
          "premium_since": null,
          "permissions": "562949953421311",
          "pending": false,
          "nick": null,
          "joined_at": "2023-06-27T12:40:26.840000+00:00",
          "flags": 10,
          "communication_disabled_until": null,
          "avatar": null
        }
      }
    },
    "options": [
      {"value": "1033681843708510238", "type": 6, "name": "target"},
      {"value": "erfhi", "type": 3, "name": "new-nick"}
    ],
    "name": "nick",
    "id": "1144994260677050489"
  },
  "channel_id": "1038831656682930227",
  "channel": {
    "type": 0,
    "topic": null,
    "rate_limit_per_user": 0,
    "position": 3,
    "permissions": "562949953421311",
    "parent_id": "1038831638836162580",
    "nsfw": false,
    "name": "testing",
    "last_message_id": "1145000144400552047",
    "id": "1038831656682930227",
    "guild_id": "1033681997136146462",
    "flags": 0
  },
  "application_id": "1033681843708510238",
  "app_permissions": "562949953421311",
};

void checkCommandInteraction2(Interaction<dynamic> interaction) {
  expect(interaction, isA<ApplicationCommandInteraction>());
}

void main() {
  group('InteractionManager', () {
    test('parse', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<InteractionManager, Interaction<dynamic>, Map<String, Object?>>(
        name: 'parse (1)',
        source: sampleCommandInteraction,
        parse: (manager) => manager.parse,
        check: checkCommandInteraction,
      ).runWithManager(InteractionManager(client, applicationId: Snowflake.zero));

      ParsingTest<InteractionManager, Interaction<dynamic>, Map<String, Object?>>(
        name: 'parse (2)',
        source: sampleCommandInteraction2,
        parse: (manager) => manager.parse,
        check: checkCommandInteraction2,
      ).runWithManager(InteractionManager(client, applicationId: Snowflake.zero));
    });

    // Endpoints are tested in webhook_manager_test.dart as the implementation is the same.
  });
}
