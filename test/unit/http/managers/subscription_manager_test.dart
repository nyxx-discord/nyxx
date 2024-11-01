import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleSubscription = {
  "id": "1278078770116427839",
  "user_id": "1088605110638227537",
  "sku_ids": ["1158857122189168803"],
  "entitlement_ids": [],
  "current_period_start": "2024-08-27T19:48:44.406602+00:00",
  "current_period_end": "2024-09-27T19:48:44.406602+00:00",
  "status": 0,
  "canceled_at": null
};

void checkSubscription(Subscription subscription) {
  expect(subscription.id, equals(Snowflake(1278078770116427839)));
  expect(subscription.userId, equals(Snowflake(1088605110638227537)));
  expect(subscription.skuIds, equals([Snowflake(1158857122189168803)]));
  expect(subscription.entitlementIds, equals([]));
  expect(subscription.currentPeriodStart, equals(DateTime.utc(2024, 08, 27, 19, 48, 44, 406, 602)));
  expect(subscription.currentPeriodEnd, equals(DateTime.utc(2024, 09, 27, 19, 48, 44, 406, 602)));
  expect(subscription.status, equals(SubscriptionStatus.active));
  expect(subscription.canceledAt, isNull);
  expect(subscription.countryCode, isNull);
}

void main() {
  testReadOnlyManager<Subscription, SubscriptionManager>(
    'SubscriptionManager',
    (client, config) => SubscriptionManager(client, config, applicationId: Snowflake.zero, skuId: Snowflake(1)),
    RegExp(r'/skus/1/subscriptions/\d+'),
    sampleObject: sampleSubscription,
    sampleMatches: checkSubscription,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<SubscriptionManager, List<Subscription>, List<Map<String, Object?>>>(
        name: 'list',
        source: [sampleSubscription],
        urlMatcher: '/skus/1/subscriptions',
        execute: (manager) => manager.list(),
        check: (subscriptions) {
          expect(subscriptions, hasLength(1));

          checkSubscription(subscriptions.single);
        },
      ),
    ],
  );
}
