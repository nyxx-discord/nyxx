import 'dart:async';

import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/models/snowflake.dart';

export 'base_impl.dart' if (dart.library.mirrors) 'mirrors_impl.dart';

/// The base class for all entities in the API identified by a [Snowflake].
abstract class SnowflakeEntity<T extends SnowflakeEntity<T>> {
  /// The id of this entity.
  final Snowflake id;

  /// The manager for this entity.
  ReadOnlyManager<T> get manager;

  /// Create a new [SnowflakeEntity];
  SnowflakeEntity({required this.id});

  /// If this entity exists in the manager's cache, return the cached instance. Otherwise, [fetch]
  /// this entity and return it.
  FutureOr<T> get() => manager.get(id);

  /// Fetch this entity from the API.
  Future<T> fetch() => manager.fetch(id);
}
