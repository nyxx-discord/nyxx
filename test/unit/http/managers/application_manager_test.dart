import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_manager.dart';

void main() {
  final sampleApplication = {
    "bot_public": true,
    "bot_require_code_grant": false,
    "cover_image": "31deabb7e45b6c8ecfef77d2f99c81a5",
    "description": "Test",
    "guild_id": "290926798626357260",
    "icon": null,
    "id": "172150183260323840",
    "name": "Baba O-Riley",
    "owner": {"avatar": null, "discriminator": "1738", "flags": 1024, "id": "172150183260323840", "username": "i own a bot"},
    "primary_sku_id": "172150183260323840",
    "slug": "test",
    "summary": "",
    "team": {
      "icon": "dd9b7dcfdf5351b9c3de0fe167bacbe1",
      "id": "531992624043786253",
      "members": [
        {
          "membership_state": 2,
          "permissions": ["*"],
          "team_id": "531992624043786253",
          "user": {"avatar": "d9e261cd35999608eb7e3de1fae3688b", "discriminator": "0001", "id": "511972282709709995", "username": "Mr Owner"}
        }
      ],

      // The docs say these fields are present, but they aren't in the sample application Discord provides
      "name": "test team",
      "owner_user_id": "0",
    },
    "verify_key": "1e0a356058d627ca38a5c8c9648818061d49e49bd9da9e3ab17d98ad4d6bg2u8"
  };

  void checkApplication(Application application) {
    expect(application.id, equals(Snowflake(172150183260323840)));
    expect(application.name, equals('Baba O-Riley'));
    expect(application.iconHash, isNull);
    expect(application.description, equals('Test'));
    expect(application.rpcOrigins, isNull);
    expect(application.isBotPublic, isTrue);
    expect(application.botRequiresCodeGrant, isFalse);
    expect(application.termsOfServiceUrl, isNull);
    expect(application.privacyPolicyUrl, isNull);
    expect(application.owner?.id, equals(Snowflake(172150183260323840)));
    expect(application.verifyKey, equals('1e0a356058d627ca38a5c8c9648818061d49e49bd9da9e3ab17d98ad4d6bg2u8'));
    expect(application.team?.id, equals(Snowflake(531992624043786253)));
    expect(application.guildId, equals(Snowflake(290926798626357260)));
    expect(application.primarySkuId, equals(Snowflake(172150183260323840)));
    expect(application.slug, equals('test'));
    expect(application.coverImageHash, equals('31deabb7e45b6c8ecfef77d2f99c81a5'));
    expect(application.flags, equals(ApplicationFlags(0)));
    expect(application.tags, isNull);
    expect(application.installationParameters, isNull);
    expect(application.customInstallUrl, isNull);
    expect(application.roleConnectionsVerificationUrl, isNull);
  }

  group('ApplicationManager', () {
    test('parse', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<ApplicationManager, Application, Map<String, Object?>>(
        name: 'parse',
        source: sampleApplication,
        parse: (manager) => manager.parse,
        check: checkApplication,
      ).runWithManager(ApplicationManager(client));
    });
  });
}
