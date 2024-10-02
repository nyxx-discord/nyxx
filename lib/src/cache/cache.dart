import 'dart:async';
import 'dart:collection';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// A manager for all the caches associated with a client.
///
/// Provides a way to obtain the [Cache] instance associated with a given cache
/// identifier. Also provides utilities to inspect all the caches in a client.
///
/// Empty caches are automatically discarded.
class CacheManager {
  /// The client this [CacheManager] is for.
  final Nyxx client;

  final Map<String, Cache<dynamic>> _caches = {};

  /// A map containing all the caches attached to [client].
  ///
  /// Cache identifiers are mapped to their respective [Cache] instances.
  Map<String, Cache<dynamic>> get caches => UnmodifiableMapView(_caches);

  final Map<String, WeakReference<Cache<dynamic>>> _emptyCaches = {};

  /// Create a new cache manager for a client.
  CacheManager(this.client);

  /// Get the cache associated with [identifier], or create it if it does not yet exist.
  ///
  /// [config] is only used if the cache does not exist and needs to be created.
  Cache<T> getCache<T>(String identifier, CacheConfig<T> config) {
    if (_caches[identifier] case final cache?) {
      if (cache is Cache<T>) {
        return cache;
      }

      throw ArgumentError('Type of cache (${cache.runtimeType}) does not match type argument ($T) for $identifier');
    }

    if (_emptyCaches[identifier] case final reference?) {
      if (reference.target case final cache?) {
        if (cache is Cache<T>) {
          return cache;
        }

        throw ArgumentError('Type of cache (${cache.runtimeType}) does not match type argument ($T) for $identifier');
      } else {
        _emptyCaches.remove(identifier);
      }
    }

    final cache = Cache._(this, identifier, config);
    _onEmpty(cache); // Cache starts out empty. Don't be afraid to discard it.
    return cache;
  }

  void _onNotEmpty(Cache<dynamic> cache) {
    _emptyCaches.remove(cache.identifier);
    _caches[cache.identifier] = cache;
  }

  void _onEmpty(Cache<dynamic> cache) {
    _caches.remove(cache.identifier);
    _emptyCaches[cache.identifier] = WeakReference(cache);
  }
}

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

final class _CacheEntry<T> extends LinkedListEntry<_CacheEntry<T>> {
  final Snowflake id;
  T value;

  _CacheEntry({required this.id, required this.value});
}

/// A simple cache for [SnowflakeEntity]s.
///
/// The underlying implementation is a basic LRU cache, limited by
/// [CacheConfig.maxSize]. Entities will not be added to the cache if
/// [CacheConfig.shouldCache] returns false.
///
/// {@template cache_filtering}
/// When the cache size exceeds [CacheConfig.maxSize], items already in the
/// cache for which [CacheConfig.shouldCache] now returns `false` are removed
/// first, then items are removed starting from the least recently accessed or
/// updated until the cache size no longer exceeds the maximum size.
/// {@endtemplate}
///
/// The underlying implementation is subject to change in future versions and
/// should not be relied on.
class Cache<T> extends MapBase<Snowflake, T> {
  /// Return a mapping of identifier to cache contents for all caches associated with [client].
  @Deprecated('Use client.cache.caches')
  static Map<String, Map<Snowflake, Object?>> cachesFor(Nyxx client) => client.cache.caches;

  /// A list containing the entries of this cache, with the most recently
  /// accessed or updated entry first.
  ///
  /// Entries are ordered most recently used first so [filterItems] can first
  /// try to remove elements based on [CacheConfig.shouldCache], before
  /// removing entries that were not recently accessed without iterating
  /// backwards.
  final LinkedList<_CacheEntry<T>> _mru = LinkedList();

  /// A mapping of entry IDs to the entries themselves.
  ///
  /// This must be kept in sync with [_mru] - items in this map must be present
  /// in [_mru].
  /// This only serves to provide O(1) access to an entry given its key,
  /// instead of iterating over [_mru].
  final Map<Snowflake, _CacheEntry<T>> _entries = {};

  /// An identifier for this cache.
  ///
  /// Two caches with the same identifier belonging to the same client are guaranteed to contain the same items.
  final String identifier;

  /// The configuration for this cache.
  final CacheConfig<T> config;

  /// The manager for this cache.
  final CacheManager manager;

  /// The client this cache is for.
  Nyxx get client => manager.client;

  Cache._(this.manager, this.identifier, this.config);

  @Deprecated('Use client.cache.getCache')
  factory Cache(Nyxx client, String identifier, CacheConfig<T> config) => client.cache.getCache(identifier, config);

  @override
  Iterable<Snowflake> get keys => _entries.keys;

  /// Filter the items in this cache so that it obeys the [config].
  ///
  /// {@macro cache_filtering}
  void filterItems() {
    final maxSize = config.maxSize;
    if (maxSize == null) return;
    final toRemoveCount = length - maxSize;
    if (toRemoveCount <= 0) return;

    final toRemove = List.filled(toRemoveCount, _mru.last);
    var count = 0;
    var definitelyRemovedIndex = length - toRemoveCount;

    for (final (index, entry) in _mru.indexed) {
      if (index >= definitelyRemovedIndex) {
        toRemove[count++] = entry;
      } else if (config.shouldCache?.call(entry.value) == false) {
        definitelyRemovedIndex++;
        toRemove[count++] = entry;
      }
    }

    for (final entry in toRemove) {
      remove(entry.id);
    }
  }

  bool _filterScheduled = false;

  /// Schedule [filterItems] to be run, if it isn't already scheduled.
  ///
  /// This allows for bulk insertions to only trigger one [filterItems] call.
  void scheduleFilterItems() {
    if (_filterScheduled) return;
    _filterScheduled = true;
    scheduleMicrotask(() {
      filterItems();
      _filterScheduled = false;
    });
  }

  void _recordUse(_CacheEntry<T> entry) {
    _mru.remove(entry);
    _mru.addFirst(entry);
  }

  @override
  T? operator [](Object? key) {
    if (_entries[key] case final entry?) {
      _recordUse(entry);
      return entry.value;
    }

    return null;
  }

  @override
  void operator []=(Snowflake key, T value) {
    if (config.shouldCache?.call(value) == false) {
      remove(key);
      return;
    }

    // We will no longer be empty after adding the entry.
    if (isEmpty) manager._onNotEmpty(this);

    final entry = _entries.update(
      key,
      (entry) => entry..value = value,
      ifAbsent: () => _CacheEntry(id: key, value: value),
    );

    _recordUse(entry);
    scheduleFilterItems();
  }

  @override
  void clear() {
    _mru.clear();
    _entries.clear();
    manager._onEmpty(this);
  }

  @override
  T? remove(Object? key) {
    final entry = _entries.remove(key);
    if (entry == null) return null;

    if (isEmpty) manager._onEmpty(this);
    _mru.remove(entry);

    return entry.value;
  }

  // Implement a more efficient containsKey method than MapBase, which
  // checks `keys.contains(key)`. In our case, this causes an iteration over
  // all items of [_lru], which can be avoided simply by checking the
  // [_entries] map.
  @override
  bool containsKey(Object? key) => _entries.containsKey(key);
}
