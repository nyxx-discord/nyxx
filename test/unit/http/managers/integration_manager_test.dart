import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleIntegration = {
  // Changed to 1 so we find it when testing fetch()
  "id": "1",
  "name": "test",
  "type": "youtube",
  "enabled": true,
  "account": {
    "id": "0",
    "name": "account name",
  },
};

void checkIntegration(Integration integration) {
  expect(integration.id, equals(Snowflake(1)));
  expect(integration.name, equals("test"));
  expect(integration.type, equals("youtube"));
  expect(integration.isEnabled, isTrue);
  expect(integration.isSyncing, isNull);
  expect(integration.roleId, isNull);
  expect(integration.enableEmoticons, isNull);
  expect(integration.expireBehavior, isNull);
  expect(integration.expireGracePeriod, isNull);
  expect(integration.user, isNull);
  expect(integration.account.id, equals(Snowflake(0)));
  expect(integration.syncedAt, isNull);
  expect(integration.subscriberCount, isNull);
  expect(integration.isRevoked, isNull);
  expect(integration.application, isNull);
  expect(integration.scopes, isNull);
}

void main() {
  testReadOnlyManager<Integration, IntegrationManager>(
    'IntegrationManager',
    (config, client) => IntegrationManager(config, client, guildId: Snowflake.zero),
    '/guilds/0/integrations',
    sampleObject: sampleIntegration,
    sampleMatches: checkIntegration,
    // Fetch internally uses list(), so we return a list
    fetchObjectOverride: [sampleIntegration],
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<IntegrationManager, List<Integration>, List<Object?>>(
        name: 'list',
        source: [sampleIntegration],
        urlMatcher: '/guilds/0/integrations',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));

          checkIntegration(list.first);
        },
      ),
      EndpointTest<IntegrationManager, void, void>(
        name: 'delete',
        method: 'DELETE',
        source: null,
        urlMatcher: '/guilds/0/integrations/0',
        execute: (manager) => manager.delete(Snowflake.zero),
        check: (_) {},
      ),
    ],
  );
}
