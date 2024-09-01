import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_endpoint.dart';
import '../../../test_manager.dart';

final sampleApplication = {
  "bot_public": true,
  "bot_require_code_grant": false,
  "cover_image": "31deabb7e45b6c8ecfef77d2f99c81a5",
  "description": "Test",
  "guild_id": "290926798626357260",
  "icon": null,
  "id": "172150183260323840",
  "integration_types_config": {
    "0": {
      "oauth2_install_params": {
        "scopes": ["applications.commands", "bot"],
        "permissions": "2048"
      }
    },
    "1": {
      "oauth2_install_params": {
        "scopes": ["applications.commands"],
        "permissions": "0"
      }
    }
  },
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
        "role": "admin",
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
  expect(application.integrationTypesConfig?[ApplicationIntegrationType.guildInstall], isNotNull);
  expect(application.integrationTypesConfig![ApplicationIntegrationType.guildInstall]!, (ApplicationIntegrationTypeConfiguration config) {
    expect(config.oauth2InstallParameters, isNotNull);
    expect(config.oauth2InstallParameters!.scopes, equals(["applications.commands", "bot"]));
    expect(config.oauth2InstallParameters!.permissions, equals(Permissions(2048)));
    return true;
  });
}

final sampleRoleConnectionMetadata = {
  'type': 1,
  'key': 'key',
  'name': 'test name',
  'description': 'test description',
};

void checkRoleConnectionMetadata(ApplicationRoleConnectionMetadata metadata) {
  expect(metadata.type, equals(ConnectionMetadataType.integerLessThanOrEqual));
  expect(metadata.key, equals('key'));
  expect(metadata.name, equals('test name'));
  expect(metadata.localizedNames, isNull);
  expect(metadata.description, equals('test description'));
  expect(metadata.localizedDescriptions, isNull);
}

final sampleSku = {
  "id": "1088510058284990888",
  "type": 5,
  "dependent_sku_id": null,
  "application_id": "788708323867885999",
  "manifest_labels": null,
  "access_type": 1,
  "name": "Test Premium",
  "features": [],
  "release_date": null,
  "premium": false,
  "slug": "test-premium",
  "flags": 128,
  "show_age_gate": false
};

void checkSku(Sku sku) {
  expect(sku.id, equals(Snowflake(1088510058284990888)));
  expect(sku.type, equals(SkuType.subscription));
  expect(sku.applicationId, equals(Snowflake(788708323867885999)));
  expect(sku.name, equals('Test Premium'));
  expect(sku.slug, equals('test-premium'));
}

void main() {
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

    test('parseApplicationRoleConnectionMetadata', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<ApplicationManager, ApplicationRoleConnectionMetadata, Map<String, Object?>>(
        name: 'parseApplicationRoleConnectionMetadata',
        source: sampleRoleConnectionMetadata,
        parse: (manager) => manager.parseApplicationRoleConnectionMetadata,
        check: checkRoleConnectionMetadata,
      ).runWithManager(ApplicationManager(client));
    });

    test('parseSku', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<ApplicationManager, Sku, Map<String, Object?>>(
        name: 'parseSku',
        source: sampleSku,
        parse: (manager) => manager.parseSku,
        check: checkSku,
      ).runWithManager(ApplicationManager(client));
    });

    testEndpoint(
      '/applications/0/role-connections/metadata',
      name: 'fetchApplicationRoleConnectionMetadata',
      (client) => client.applications.fetchApplicationRoleConnectionMetadata(Snowflake.zero),
      response: [sampleRoleConnectionMetadata],
    );

    testEndpoint(
      '/applications/0/role-connections/metadata',
      method: 'PUT',
      name: 'updateApplicationRoleConnectionMetadata',
      (client) => client.applications.updateApplicationRoleConnectionMetadata(Snowflake.zero),
      response: [sampleRoleConnectionMetadata],
    );

    testEndpoint(
      '/applications/@me',
      (client) => client.applications.fetchCurrentApplication(),
      response: sampleApplication,
    );

    testEndpoint(
      '/applications/@me',
      method: 'PATCH',
      (client) => client.applications.updateCurrentApplication(ApplicationUpdateBuilder()),
      response: sampleApplication,
    );

    testEndpoint(
      '/applications/0/skus',
      (client) => client.applications.listSkus(Snowflake.zero),
      response: [sampleSku],
    );
  });
}
