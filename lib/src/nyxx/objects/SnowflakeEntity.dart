part of nyxx;

/// Provides identity for all entities with id as [Snowflake]
/// Includes only actual id of entity and [createdAt] which is timestamp when entity was created.
class SnowflakeEntity {
  /// Snowflake id
  Snowflake id;

  SnowflakeEntity(this.id);

  /// Gets creation timestamp included in [Snowflake]
  DateTime get createdAt => id.timestamp;

  @override
  int get hashCode => id.id.hashCode;

  @override
  bool operator ==(other) {
    if (other is SnowflakeEntity) return id == other.id;
    if (other is String) return id.id == other;

    return false;
  }
}
