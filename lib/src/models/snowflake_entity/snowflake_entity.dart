import 'dart:async';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The base class for all entities in the API identified by a [Snowflake].
abstract class SnowflakeEntity<T extends SnowflakeEntity<T>> with ToStringHelper {
  /// The id of this entity.
  final Snowflake id;

  /// Create a new [SnowflakeEntity].
  SnowflakeEntity({required this.id});

  /// If this entity exists in the manager's cache, return the cached instance. Otherwise, [fetch]
  /// this entity and return it.
  Future<T> get();

  /// Fetch this entity from the API.
  Future<T> fetch();

  @override
  bool operator ==(Object other) => identical(this, other) || (other is SnowflakeEntity<T> && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String defaultToString() => '$T($id)';
}

/// The base class for all [SnowflakeEntity]'s that have a dedicated [ReadOnlyManager].
abstract class ManagedSnowflakeEntity<T extends ManagedSnowflakeEntity<T>> extends SnowflakeEntity<T> {
  /// The manager for this entity.
  ReadOnlyManager<T> get manager;

  /// Create a new [ManagedSnowflakeEntity];
  ManagedSnowflakeEntity({required super.id});

  @override
  Future<T> get() => manager.get(id);

  @override
  Future<T> fetch() => manager.fetch(id);
}

/// The base class for all [SnowflakeEntity]'s that have a dedicated [Manager].
abstract class WritableSnowflakeEntity<T extends WritableSnowflakeEntity<T>> extends ManagedSnowflakeEntity<T> {
  @override
  Manager<T> get manager;

  /// Create a new [WritableSnowflakeEntity].
  WritableSnowflakeEntity({required super.id});

  /// Update this entity using the provided builder and return the updated entity.
  Future<T> update(covariant UpdateBuilder<T> builder) => manager.update(id, builder);

  /// Delete this entity.
  Future<void> delete() => manager.delete(id);
}
