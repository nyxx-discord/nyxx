
import 'dart:collection';

import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/message/Message.dart';

// typedef Cache<T> = Map<Snowflake, T>;
//
// extension CacheExtensions on Cache {
//
// }

class MessageCache extends SnowflakeCache<IMessage> {
  final int cacheSize;

  MessageCache(this.cacheSize) : super();

  IMessage put(IMessage message) {
    if (this.length <= this.cacheSize) {
      this[message.id] = message;
    }

    return message;
  }
}

class SnowflakeCache<V> implements Map<Snowflake, V> {
  final Map<Snowflake, V> _map;

  /// Creates an instance of [SnowflakeCache]
  const SnowflakeCache([Map<Snowflake, V> map = const {}]) : _map = map;

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();
  @override
  V? operator [](Object? key) => _map[key];
  @override
  void operator []=(Snowflake key, V value) {
    _map[key] = value;
  }

  @override
  void addAll(Map<Snowflake, V> other) {
    _map.addAll(other);
  }

  @override
  void clear() {
    _map.clear();
  }

  @override
  V putIfAbsent(Snowflake key, V Function() ifAbsent) => _map.putIfAbsent(key, ifAbsent);
  @override
  bool containsKey(Object? key) => _map.containsKey(key);
  @override
  bool containsValue(Object? value) => _map.containsValue(value);
  @override
  void forEach(void Function(Snowflake key, V value) action) {
    _map.forEach(action);
  }

  @override
  bool get isEmpty => _map.isEmpty;
  @override
  bool get isNotEmpty => _map.isNotEmpty;
  @override
  int get length => _map.length;
  @override
  Iterable<Snowflake> get keys => _map.keys;
  @override
  V? remove(Object? key) => _map.remove(key);
  @override
  String toString() => _map.toString();
  @override
  Iterable<V> get values => _map.values;

  @override
  Iterable<MapEntry<Snowflake, V>> get entries => _map.entries;

  @override
  void addEntries(Iterable<MapEntry<Snowflake, V>> entries) {
    _map.addEntries(entries);
  }

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(Snowflake key, V value) transform) =>
      _map.map<K2, V2>(transform);

  @override
  V update(Snowflake key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _map.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(Snowflake key, V value) update) {
    _map.updateAll(update);
  }

  @override
  void removeWhere(bool Function(Snowflake key, V value) test) {
    _map.removeWhere(test);
  }
}
