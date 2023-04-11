import 'dart:async';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// A [Manager] that provides only read access to the API.
abstract class ReadOnlyManager<T extends SnowflakeEntity<T>> {
  /// The cache for this manager.
  final Cache<T> cache;

  /// The client this manager belongs to.
  final NyxxRest client;

  /// Create a new read-only manager.
  // TODO: Do we really want to use `T.toString()` as the cache identifier?
  ReadOnlyManager(CacheConfig<T> config, this.client) : cache = Cache(T.toString(), config);

  /// Parse the [raw] data received from the API into an instance of the type of this manager.
  T parse(Map<String, Object?> raw);

  /// Get an item by its [id] from the cache if it exists, else [fetch] it from the API.
  FutureOr<T> get(Snowflake id) async => cache[id] ?? await fetch(id);

  /// Fetch the item with the given [id] from the API.
  ///
  /// {@macro ensure_cache_updated}
  Future<T> fetch(Snowflake id);

  /// Return a partial instance of the entity with ID [id] containing no data.
  ///
  /// This allows performing API operations without fetching an instance from the API.
  ///
  /// Because this method doesn't perform any API checks, there might be no real entity with the
  /// correct [id]. In this case, the object returned may not work with the API correctly.
  SnowflakeEntity<T> operator [](Snowflake id);
}

/// Provides the means to interact with the API for a given entity type.
///
/// {@template manager}
/// Managers provide methods for creating objects ([create]), caching them ([cache] and [get]),
/// fetching them from the API ([fetch]), updating them ([update]) and deleting them ([delete]).
///
/// [parse] can be used to convert a raw API response into an instance of the managed type.
///
/// {@endtemplate}
abstract class Manager<T extends SnowflakeEntity<T>> extends ReadOnlyManager<T> {
  /// Create a new manager.
  ///
  /// {@macro manager}
  Manager(super.config, super.client);

  /// Create a new instance of the type of this manager.
  ///
  /// {@template ensure_cache_updated}
  /// Implementers should ensure this method updates the [cache].
  /// {@endtemplate}
  Future<T> create(covariant CreateBuilder<T> builder);

  /// Update the item with the given [id] in the API.
  ///
  /// {@macro ensure_cache_updated}
  Future<T> update(Snowflake id, covariant UpdateBuilder<T> builder);

  /// Delete the item with the given [id] from the API.
  ///
  /// {@macro ensure_cache_updated}
  Future<void> delete(Snowflake id);
}
