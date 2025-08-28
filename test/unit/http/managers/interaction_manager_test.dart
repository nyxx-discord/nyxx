import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_manager.dart';
import 'message_manager_test.dart';

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
  "authorizing_integration_owners": {
    "0": "846136758470443069",
    "1": "302359032612651009",
  },
  "context": 0,

  // Fields not present in the example but documented
  "application_id": "0",
  "version": 1,
  "attachment_size_limit": 4096
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
  expect(
      interaction.authorizingIntegrationOwners,
      equals({
        ApplicationIntegrationType.guildInstall: Snowflake(846136758470443069),
        ApplicationIntegrationType.userInstall: Snowflake(302359032612651009),
      }));
  expect(interaction.context, equals(InteractionContextType.guild));
  expect(interaction.attachmentSizeLimit, equals(4096));
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
  "authorizing_integration_owners": {
    "0": "846136758470443069",
    "1": "302359032612651009",
  },
  'attachment_size_limit': 4096
};

final interactionCallbackResponseObject = {
  'interaction': {
    'id': 123456789123456789,
    'type': 2,
    'activity_instance_id': 'SomeRandomId',
    'response_message_loading': true,
    'response_message_ephemeral': true,
  },
  'resource': {
    'type': 4,
    'activity_instance': {
      'id': 'AnotherRandomId',
    },
    'message': sampleMessage,
  }
};

void checkCommandInteraction2(Interaction<dynamic> interaction) {
  expect(interaction, isA<ApplicationCommandInteraction>());
}

void checkInteractionCallbackResponse(InteractionCallbackResponse interactionCallbackResponse) {
  checkInteractionCallback(interactionCallbackResponse.interaction);
}

void checkInteractionCallback(InteractionCallback interactionCallback) {
  expect(interactionCallback.activityInstanceId, equals('SomeRandomId'));
  expect(interactionCallback.id, equals(const Snowflake(123456789123456789)));
  expect(interactionCallback.responseMessageEphemeral, equals(true));
  expect(interactionCallback.responseMessageLoading, equals(true));
}

void checkInteractionResource(InteractionResource resource) {
  checkMessage(resource.message!);
  expect(resource.type, equals(InteractionCallbackType.channelMessageWithSource));
  expect(resource.activityInstance, isA<InteractionCallbackActivityInstanceResource>());
  expect(resource.activityInstance!.id, equals('AnotherRandomId'));
}

final sampleModalSubmitInteraction = {
  "version": 1,
  "type": 5,
  "token":
      "aW50ZXJhY3Rpb246MTQwNjkzODE2NjU4MTEzMzQ3NDo0QzlheVQ4ejF4QzBKVVdLTTBtcXRQc2dZVnpwNDRXbTY2VFR2V0s2OHdGRmtVc1o1MEhPNXlFbkZwMjdmYkNteWhvaEpESE5qbzJlcW9iRDJHZlMwMmJxRE1DUTRqS1dEVkpCSVlYejNvMUNyQlZwQnJ1WUNoV3RpRXdnYllrdg",
  "member": {
    "user": {
      "username": "abitofevrything",
      "public_flags": 128,
      "primary_guild": null,
      "id": "506759329068613643",
      "global_name": "Mylo",
      "display_name_styles": null,
      "discriminator": "0",
      "collectibles": null,
      "clan": null,
      "avatar_decoration_data": null,
      "avatar": "b591ea8a9d057669ea2a6cd3ab450301"
    },
    "unusual_dm_activity_until": null,
    "roles": ["1336784655155986432", "1403111146944467114", "1403115171127234704"],
    "premium_since": null,
    "permissions": "2222085186637376",
    "pending": false,
    "nick": null,
    "mute": false,
    "joined_at": "2024-12-15T21:11:08.816000+00:00",
    "flags": 2,
    "deaf": false,
    "communication_disabled_until": null,
    "collectibles": null,
    "banner": null,
    "avatar": null
  },
  "locale": "en-GB",
  "id": "1406938166581133474",
  "guild_locale": "en-US",
  "guild_id": "1317206872763404478",
  "guild": {
    "locale": "en-US",
    "id": "1317206872763404478",
    "features": [
      "VANITY_URL",
      "ACTIVITY_FEED_DISABLED_BY_USER",
      "BANNER",
      "VIDEO_QUALITY_720_60FPS",
      "PREMIUM_TIER_3_OVERRIDE",
      "COMMUNITY",
      "ANIMATED_ICON",
      "ROLE_ICONS",
      "TIERLESS_BOOSTING_SYSTEM_MESSAGE",
      "AUDIO_BITRATE_128_KBPS",
      "VIDEO_BITRATE_ENHANCED",
      "ANIMATED_BANNER",
      "STAGE_CHANNEL_VIEWERS_150",
      "NEWS",
      "INVITE_SPLASH",
      "MAX_FILE_SIZE_100_MB",
      "GUILD_ONBOARDING",
      "STAGE_CHANNEL_VIEWERS_50",
      "RAID_ALERTS_DISABLED",
      "MAX_FILE_SIZE_50_MB",
      "GUILD_ONBOARDING_EVER_ENABLED",
      "AUDIO_BITRATE_384_KBPS",
      "STAGE_CHANNEL_VIEWERS_300",
      "AUDIO_BITRATE_256_KBPS",
      "VIDEO_QUALITY_1080_60FPS",
      "GUILD_ONBOARDING_HAS_PROMPTS",
      "AUTO_MODERATION"
    ]
  },
  "entitlements": [],
  "entitlement_sku_ids": [],
  "data": {
    "custom_id": "fooo",
    "components": [
      {
        "type": 18,
        "id": 1,
        "component": {
          "values": ["two"],
          "type": 3,
          "id": 4,
          "custom_id": "foo"
        }
      },
      {
        "type": 1,
        "id": 2,
        "components": [
          {"value": "Fooooo", "type": 4, "id": 3, "custom_id": "fppp"}
        ]
      }
    ]
  },
  "context": 0,
  "channel_id": "1317207700261834803",
  "channel": {
    "type": 0,
    "topic": null,
    "rate_limit_per_user": 0,
    "position": 11,
    "permissions": "2222085186637376",
    "parent_id": "1317206872763404479",
    "nsfw": false,
    "name": "playground-1",
    "last_message_id": "1406936192187891783",
    "id": "1317207700261834803",
    "guild_id": "1317206872763404478",
    "flags": 0
  },
  "authorizing_integration_owners": {"1": "506759329068613643", "0": "1317206872763404478"},
  "attachment_size_limit": 104857600,
  "application_id": "1033681843708510238",
  "app_permissions": "2222085186637376"
};

void checkModalSubmitInteraction(Interaction<dynamic> interaction) {
  expect(interaction, isA<ModalSubmitInteraction>());
  interaction as ModalSubmitInteraction;

  expect(interaction.id, equals(Snowflake(1406938166581133474)));
  expect(interaction.applicationId, equals(Snowflake(1033681843708510238)));
  expect(interaction.type, equals(InteractionType.modalSubmit));
  expect(interaction.data, (ModalSubmitInteractionData data) {
    expect(data.customId, equals('fooo'));
    expect(data.components[0], (SubmittedLabelComponent component) {
      expect(component.component, (SubmittedSelectMenuComponent component) {
        expect(component.customId, equals('foo'));
        expect(component.values, equals(['two']));

        return true;
      });

      return true;
    });

    expect(data.components[1], (SubmittedActionRowComponent component) {
      expect(component.components.single, (SubmittedTextInputComponent component) {
        expect(component.customId, equals('fppp'));
        expect(component.value, equals('Fooooo'));

        return true;
      });

      return true;
    });

    return true;
  });
  expect(interaction.guildId, equals(Snowflake(1317206872763404478)));
  expect(interaction.channel?.id, equals(Snowflake(1317207700261834803)));
  expect(interaction.channelId, equals(Snowflake(1317207700261834803)));
  expect(interaction.member?.id, equals(Snowflake(506759329068613643)));
  expect(interaction.user, isNull);
  expect(
      interaction.token,
      equals(
          'aW50ZXJhY3Rpb246MTQwNjkzODE2NjU4MTEzMzQ3NDo0QzlheVQ4ejF4QzBKVVdLTTBtcXRQc2dZVnpwNDRXbTY2VFR2V0s2OHdGRmtVc1o1MEhPNXlFbkZwMjdmYkNteWhvaEpESE5qbzJlcW9iRDJHZlMwMmJxRE1DUTRqS1dEVkpCSVlYejNvMUNyQlZwQnJ1WUNoV3RpRXdnYllrdg'));
  expect(interaction.version, equals(1));
  expect(interaction.message, isNull);
  expect(interaction.appPermissions, equals(Permissions(2222085186637376)));
  expect(interaction.locale, equals(Locale.enGb));
  expect(interaction.guildLocale, equals(Locale.enUs));
  expect(interaction.entitlements, equals([]));
  expect(
      interaction.authorizingIntegrationOwners,
      equals({
        ApplicationIntegrationType.guildInstall: Snowflake(1317206872763404478),
        ApplicationIntegrationType.userInstall: Snowflake(506759329068613643),
      }));
  expect(interaction.context, equals(InteractionContextType.guild));
  expect(interaction.attachmentSizeLimit, equals(104857600));
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

      ParsingTest<InteractionManager, InteractionCallbackResponse, Map<String, Object?>>(
        name: 'parse interaction callback response',
        source: interactionCallbackResponseObject,
        check: checkInteractionCallbackResponse,
        parse: (manager) => manager.parseInteractionCallbackResponse,
      ).runWithManager(InteractionManager(client, applicationId: Snowflake.zero));

      ParsingTest<InteractionManager, Interaction<dynamic>, Map<String, Object?>>(
        name: 'parse (3)',
        source: sampleModalSubmitInteraction,
        parse: (manager) => manager.parse,
        check: checkModalSubmitInteraction,
      ).runWithManager(InteractionManager(client, applicationId: Snowflake.zero));
    });

    // Endpoints are tested in webhook_manager_test.dart as the implementation is the same.
  });
}
