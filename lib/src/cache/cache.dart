import 'dart:async';
import 'dart:collection';

import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// The configuration for a [Cache] instance.
class CacheConfig<T extends SnowflakeEntity<T>> {
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
class Cache<T extends SnowflakeEntity<T>> with MapMixin<Snowflake, T> {
  final SplayTreeMap<Snowflake, T> _store = SplayTreeMap();
  final HashMap<Snowflake, int> _counts = HashMap();

  /// The configuration for this cache.
  final CacheConfig<T> config;

  /// Create a new cache with the provided config.
  Cache(this.config);

  /// Filter the items in the cache so that it obeys the [config].
  ///
  /// Items are retained based on the number of accesses they have until the [CacheConfig.maxSize]
  /// is respected.
  void filterItems() {
    if (config.maxSize != null && _store.length > config.maxSize!) {
      final items = List.of(_store.keys);
      items.sort((a, b) => _counts[a]!.compareTo(_counts[b]!));

      final overflow = _store.length - config.maxSize!;

      for (final item in items.take(overflow)) {
        _store.remove(item);
        _counts.remove(item);
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
    assert(key == value.id, 'Mismatched entity key in cache');

    if (config.shouldCache?.call(value) == false) {
      return;
    }

    _store[key] = value;
    _counts[key] ??= 0;

    scheduleFilterItems();
  }

  @override
  T? operator [](Object? key) {
    if (key is! Snowflake) {
      return null;
    }

    final value = _store[key];
    if (value != null) {
      _counts.update(key, (value) => value + 1);
    }
    return value;
  }

  @override
  void clear() {
    _store.clear();
    _counts.clear();
  }

  @override
  Iterable<Snowflake> get keys => _store.keys;

  @override
  T? remove(Object? key) {
    _counts.remove(key);
    return _store.remove(key);
  }
}