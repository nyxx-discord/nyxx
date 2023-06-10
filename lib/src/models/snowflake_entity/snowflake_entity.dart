import 'dart:async';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/models/snowflake.dart';

export 'base_impl.dart' if (dart.library.mirrors) 'mirrors_impl.dart';

abstract class SnowflakeEntity<T extends SnowflakeEntity<T>> {
  /// The id of this entity.
  final Snowflake id;

  SnowflakeEntity({required this.id});

  /// If this entity exists in the manager's cache, return the cached instance. Otherwise, [fetch]
  /// this entity and return it.
  FutureOr<T> get();

  /// Fetch this entity from the API.
  Future<T> fetch();

  @override
  bool operator ==(Object other) => identical(this, other) || (other is SnowflakeEntity<T> && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// The base class for all entities in the API identified by a [Snowflake].
abstract class ManagedSnowflakeEntity<T extends ManagedSnowflakeEntity<T>> extends SnowflakeEntity<T> {
  /// The manager for this entity.
  ReadOnlyManager<T> get manager;

  /// Create a new [ManagedSnowflakeEntity];
  ManagedSnowflakeEntity({required super.id});

  @override
  FutureOr<T> get() => manager.get(id);

  @override
  Future<T> fetch() => manager.fetch(id);
}

abstract class WritableSnowflakeEntity<T extends WritableSnowflakeEntity<T>> extends ManagedSnowflakeEntity<T> {
  @override
  Manager<T> get manager;

  WritableSnowflakeEntity({required super.id});

  Future<T> update(covariant UpdateBuilder<T> builder) => manager.update(id, builder);

  Future<void> delete() => manager.delete(id);
}
