part of nyxx;

class SnowflakeEntity {
  Snowflake id;

  SnowflakeEntity(this.id);

  DateTime get createdAt => id.timestamp;

  @override
  int get hashCode => id.id.hashCode;

  @override
  bool operator ==(other) {
    if(other is SnowflakeEntity)
      return id == other.id;

    if(other is String)
      return id == other;

    return false;
  }
}