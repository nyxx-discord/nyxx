part of nyxx;

/// Marks a snowflake entity. Snowflake entities are ones that have an id that uniquely identifies them.
/// Includes only actual id of entity and [createdAt] which is timestamp when entity was created.
class SnowflakeEntity {
  /// ID of entity as Snowflake
  final Snowflake id;

  /// Creates new snowflake
  const SnowflakeEntity(this.id);

  /// Gets creation timestamp included in [Snowflake]
  DateTime get createdAt => id.timestamp;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id.toString();

  @override
  bool operator ==(dynamic other) {
    if (other is SnowflakeEntity) return id == other.id;
    if (other is String) return id.id.toString() == other;
    if (other is int) return id.id == other;

    return false;
  }
}
