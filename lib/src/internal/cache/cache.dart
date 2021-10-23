import 'dart:collection';

import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/message/message.dart';

class MessageCache extends SnowflakeCache<IMessage> {
  final int cacheSize;

  /// Creates instance of cache that has finite size.
  /// New entry will replace entries that are the longest in cache
  MessageCache(this.cacheSize) : super();

  IMessage put(IMessage message) {
    if (this.length <= this.cacheSize) {
      this.remove(this.keys.first);
      this[message.id] = message;
    }

    return message;
  }
}

class SnowflakeCache<V> extends MapMixin<Snowflake, V> {
  final Map<Snowflake, V> _map = {};

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(Snowflake key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<Snowflake> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);
}
