import 'dart:async';
import 'dart:collection';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// The configuration for a [Cache] instance.
class CacheConfig<T> {
  /// The maximum amount of items allowed in the cache.
  final int? maxSize;

  /// A predicate determining whether a given item should be cached.
  ///
  /// This function is called whenever an item is added to the cache. If it returns `true`, the item
  /// is added and can later be retrieved. If it returns false, the item is not added.
  ///
  /// The default is to add all items to the cache.
  final bool Function(T item)? shouldCache;

  /// Create a new [CacheConfig] with the provided properties.
  const CacheConfig({this.maxSize, this.shouldCache});
}

typedef _CacheKey = ({String identifier, Snowflake key});

class _CacheEntry {
  Object? value;
  int accessCount;

  _CacheEntry(this.value) : accessCount = 0;
}

/// A simple cache for [SnowflakeEntity]s.
class Cache<T> with MapMixin<Snowflake, T> {
  static final Expando<Map<_CacheKey, _CacheEntry>> _stores = Expando('Cache store');

  Map<_CacheKey, _CacheEntry> get _store => _stores[client] ??= {};

  /// The configuration for this cache.
  final CacheConfig<T> config;

  /// An identifier for this cache.
  ///
  /// Caches with the same identifier will use the same backing store, so this allows for multiple caches pointing to the same resource to exist.
  final String identifier;

  /// The client this cache is associated with.
  final Nyxx client;

  /// Create a new cache with the provided config.
  Cache(this.client, this.identifier, this.config);

  /// Filter the items in the cache so that it obeys the [config].
  ///
  /// Items are retained based on the number of accesses they have until the [CacheConfig.maxSize]
  /// is respected.
  void filterItems() {
    final keys = List.of(_store.keys.where((element) => element.identifier == identifier));

    if (config.maxSize != null && keys.length > config.maxSize!) {
      keys.sort((a, b) => _store[a]!.accessCount.compareTo(_store[b]!.accessCount));

      final overflow = keys.length - config.maxSize!;

      for (final key in keys.take(overflow)) {
        _store.remove(key);
      }
    }
  }

  bool _resizeScheduled = false;

  /// Schedule [filterItems] to be run, if it isn't already scheduled.
  ///
  /// This allows for bulk insertions to only trigger one [filterItems] call.
  void scheduleFilterItems() {
    if (!_resizeScheduled) {
      _resizeScheduled = true;
      scheduleMicrotask(() {
        filterItems();
        _resizeScheduled = false;
      });
    }
  }

  @override
  void operator []=(Snowflake key, T value) {
    assert(value is! ManagedSnowflakeEntity || value.id == key, 'Mismatched entity key in cache');

    if (config.shouldCache?.call(value) == false) {
      remove(key);
      return;
    }

    _store.update(
      (identifier: identifier, key: key),
      (entry) => entry..value = value,
      ifAbsent: () => _CacheEntry(value),
    );

    scheduleFilterItems();
  }

  @override
  T? operator [](Object? key) {
    if (key is! Snowflake) {
      return null;
    }

    final entry = _store[(identifier: identifier, key: key)];
    if (entry == null) {
      return null;
    }

    entry.accessCount++;
    return entry.value as T;
  }

  @override
  void clear() {
    _store.removeWhere((key, value) => key.identifier == identifier);
  }

  @override
  Iterable<Snowflake> get keys => _store.keys.where((element) => element.identifier == identifier).map((e) => e.key);

  @override
  T? remove(Object? key) {
    return _store.remove((identifier: identifier, key: key))?.value as T?;
  }

  /// Return a mapping of identifier to cache contents for all caches associated with [client].
  static Map<String, Map<Snowflake, Object?>> cachesFor(Nyxx client) {
    final store = _stores[client];
    if (store == null) {
      return {};
    }

    final result = <String, Map<Snowflake, Object?>>{};

    for (final entry in store.entries) {
      (result[entry.key.identifier] ??= {})[entry.key.key] = entry.value.value;
    }

    return result;
  }
}
