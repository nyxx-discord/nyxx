import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleEntitlement = {
  "id": "1019653849998299136",
  "sku_id": "1019475255913222144",
  "application_id": "1019370614521200640",
  "user_id": "771129655544643584",
  "promotion_id": null,
  "type": 8,
  "deleted": false,
  "gift_code_flags": 0,
  "consumed": false,
  "starts_at": "2022-09-14T17:00:18.704163+00:00",
  "ends_at": "2022-10-14T17:00:18.704163+00:00",
  "guild_id": "1015034326372454400",
  "subscription_id": "1019653835926409216"
};

void checkEntitlement(Entitlement entitlement) {
  expect(entitlement.id, equals(Snowflake(1019653849998299136)));
  expect(entitlement.skuId, equals(Snowflake(1019475255913222144)));
  expect(entitlement.userId, equals(Snowflake(771129655544643584)));
  expect(entitlement.guildId, isNull);
  expect(entitlement.applicationId, equals(Snowflake(1019370614521200640)));
  expect(entitlement.type, equals(EntitlementType.applicationSubscription));
  expect(entitlement.isConsumed, isFalse);
  expect(entitlement.startsAt, equals(DateTime.utc(2022, 09, 14, 17, 0, 18, 704, 163)));
  expect(entitlement.endsAt, equals(DateTime.utc(2022, 10, 14, 17, 0, 18, 704, 163)));
}

void main() {
  testReadOnlyManager<Entitlement, EntitlementManager>(
    'EntitlementManager',
    (config, client) => EntitlementManager(config, client, applicationId: Snowflake.zero),
    // fetch() artificially creates a before field as before = id + 1 - testing ID is 1 so before is 2
    '/applications/0/entitlements?before=2',
    sampleObject: sampleEntitlement,
    // Fetch implementation internally uses `list()`, so we return a full audit log
    fetchObjectOverride: [sampleEntitlement],
    sampleMatches: checkEntitlement,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<EntitlementManager, List<Entitlement>, List<Object?>>(
        name: 'list',
        source: [sampleEntitlement],
        urlMatcher: '/applications/0/entitlements',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkEntitlement(list.single);
        },
      ),
      EndpointTest<EntitlementManager, Entitlement, Map<String, Object?>>(
        name: 'createTestEntitlement',
        method: 'POST',
        source: sampleEntitlement,
        urlMatcher: '/applications/0/entitlements',
        execute: (manager) => manager
            .createTestEntitlement(TestEntitlementBuilder(skuId: Snowflake.zero, ownerId: Snowflake.zero, ownerType: TestEntitlementType.userSubscription)),
        check: checkEntitlement,
      ),
      EndpointTest<EntitlementManager, void, void>(
        name: 'deleteTestEntitlement',
        method: 'DELETE',
        source: null,
        urlMatcher: '/applications/0/entitlements/1',
        execute: (manager) => manager.deleteTestEntitlement(Snowflake(1)),
        check: (_) {},
      ),
    ],
  );
}
