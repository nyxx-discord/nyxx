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

/// A simple cache for [SnowflakeEntity]s.
class Cache<T> with MapMixin<Snowflake, T> {
  static final Expando<Map<String, Map<Snowflake, dynamic>>> _stores = Expando('Cache stores');
  static final Expando<Map<String, Map<Snowflake, int>>> _counts = Expando('Cache counts');

  // References to the backing store for this Cache instance to avoid looking up the client & identifier every time.
  late final Map<Snowflake, T> _store = ((_stores[client] ??= {})[identifier] ??= <Snowflake, T>{}) as Map<Snowflake, T>;
  late final Map<Snowflake, int> _count = (_counts[client] ??= {})[identifier] ??= {};

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
    if (config.maxSize != null && _store.length > config.maxSize!) {
      final items = List.of(_store.keys);
      items.sort((a, b) => _count[a]!.compareTo(_count[b]!));

      final overflow = _store.length - config.maxSize!;

      for (final item in items.take(overflow)) {
        _store.remove(item);
        _count.remove(item);
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
      return;
    }

    _store[key] = value;
    _count[key] ??= 0;

    scheduleFilterItems();
  }

  @override
  T? operator [](Object? key) {
    if (key is! Snowflake) {
      return null;
    }

    final store = _stores[identifier]!;

    final value = store[key] as T?;
    if (value != null) {
      _count.update(key, (value) => value + 1);
    }
    return value;
  }

  @override
  void clear() {
    _stores[identifier]!.clear();
    _counts[identifier]!.clear();
  }

  @override
  Iterable<Snowflake> get keys => _store.keys;

  @override
  T? remove(Object? key) {
    _counts[identifier]!.remove(key);
    return _stores[identifier]!.remove(key) as T?;
  }
}
