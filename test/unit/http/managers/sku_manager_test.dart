import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/http/managers/sku_manager.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleSku = {
  "id": "1",
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
  expect(sku.id, equals(Snowflake(1)));
  expect(sku.type, equals(SkuType.subscription));
  expect(sku.applicationId, equals(Snowflake(788708323867885999)));
  expect(sku.name, equals('Test Premium'));
  expect(sku.slug, equals('test-premium'));
}

void main() {
  testReadOnlyManager<Sku, SkuManager>(
    'SkuManager',
    (config, client) => SkuManager(config, client, applicationId: Snowflake.zero),
    '/applications/0/skus',
    sampleObject: sampleSku,
    fetchObjectOverride: [sampleSku],
    sampleMatches: checkSku,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<SkuManager, List<Sku>, List<Map<String, Object?>>>(
        name: 'list',
        source: [sampleSku],
        urlMatcher: '/applications/0/skus',
        execute: (manager) => manager.list(),
        check: (skus) {
          expect(skus, hasLength(1));

          checkSku(skus.single);
        },
      ),
    ],
  );
}
