import 'dart:collection';

import 'package:nyxx/src/core/snowflake.dart';

class SnowflakeCache<V> extends InMemoryCache<Snowflake, V> {
  final int cacheSize;

  /// Creates instance of cache that has finite size.
  /// New entry will replace entries that are the longest in cache
  SnowflakeCache([this.cacheSize = -1]) : super();

  @override
  void operator []=(Snowflake key, V value) {
    if (cacheSize <= 0) {
      return;
    }

    if (length >= cacheSize) {
      remove(keys.first);
    }

    _map[key] = value;
  }
}

abstract class InMemoryCache<K, V> extends MapMixin<K, V> implements ICache<K, V> {
  final Map<K, V> _map = {};

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);
}

abstract class ICache<K, V> implements MapMixin<K, V> {}
