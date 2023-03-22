import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:test/test.dart';

class MockSnowflakeEntity extends SnowflakeEntity<MockSnowflakeEntity> with Fake {
  MockSnowflakeEntity({required super.id});
}

void main() {
  group('Cache', () {
    test('stores entities', () async {
      final cache = Cache<MockSnowflakeEntity>(CacheConfig());

      final entity = MockSnowflakeEntity(id: Snowflake.zero);

      cache[entity.id] = entity;

      expect(cache[entity.id], same(entity));

      await null;

      // The cache filter shouldn't evict this item
      expect(cache[entity.id], same(entity));
    });

    test('respects maximum size', () async {
      final cache = Cache<MockSnowflakeEntity>(CacheConfig(maxSize: 3));

      final entity1 = MockSnowflakeEntity(id: Snowflake(1));
      final entity2 = MockSnowflakeEntity(id: Snowflake(2));
      final entity3 = MockSnowflakeEntity(id: Snowflake(3));
      final entity4 = MockSnowflakeEntity(id: Snowflake(4));
      final entity5 = MockSnowflakeEntity(id: Snowflake(5));

      for (final entity in [entity1, entity2, entity3, entity4, entity5]) {
        cache[entity.id] = entity;
      }

      await null;

      expect(cache, hasLength(3));
    });

    test('keeps most used items', () async {
      final cache = Cache<MockSnowflakeEntity>(CacheConfig(maxSize: 3));

      final entity1 = MockSnowflakeEntity(id: Snowflake(1));
      final entity2 = MockSnowflakeEntity(id: Snowflake(2));
      final entity3 = MockSnowflakeEntity(id: Snowflake(3));
      final entity4 = MockSnowflakeEntity(id: Snowflake(4));
      final entity5 = MockSnowflakeEntity(id: Snowflake(5));

      for (final entity in [entity1, entity2, entity3, entity4, entity5]) {
        cache[entity.id] = entity;
      }

      for (int i = 0; i < 10; i++) {
        // Bump up access count
        cache[entity1.id];
        cache[entity3.id];
        cache[entity5.id];
      }

      await null;

      expect(cache.containsKey(entity1.id), isTrue);
      expect(cache.containsKey(entity3.id), isTrue);
      expect(cache.containsKey(entity5.id), isTrue);

      expect(cache.containsKey(entity2.id), isFalse);
      expect(cache.containsKey(entity4.id), isFalse);
    });

    test("doesn't cache items if a filter is provided", () {
      final cache = Cache<MockSnowflakeEntity>(CacheConfig(shouldCache: (e) => e.id.value > 3));

      final entity1 = MockSnowflakeEntity(id: Snowflake(1));
      final entity2 = MockSnowflakeEntity(id: Snowflake(2));
      final entity3 = MockSnowflakeEntity(id: Snowflake(3));
      final entity4 = MockSnowflakeEntity(id: Snowflake(4));
      final entity5 = MockSnowflakeEntity(id: Snowflake(5));

      for (final entity in [entity1, entity2, entity3, entity4, entity5]) {
        cache[entity.id] = entity;
      }

      expect(cache.containsKey(entity1.id), isFalse);
      expect(cache.containsKey(entity2.id), isFalse);
      expect(cache.containsKey(entity3.id), isFalse);

      expect(cache.containsKey(entity4.id), isTrue);
      expect(cache.containsKey(entity5.id), isTrue);
    });
  });
}