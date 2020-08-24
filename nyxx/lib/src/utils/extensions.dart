part of nyxx;

/// Extension on int
extension IntExtensions on int {
  /// Converts int to [Snowflake]
  Snowflake toSnowflake() => Snowflake(this);

  /// Converts int to [SnowflakeEntity]
  SnowflakeEntity toSnowflakeEntity() => SnowflakeEntity(this.toSnowflake());
}

/// Extension on int
extension StringExtensions on String {
  /// Converts String to [Snowflake]
  Snowflake toSnowflake() => Snowflake(this);

  /// Converts String to [SnowflakeEntity]
  SnowflakeEntity toSnowflakeEntity() => SnowflakeEntity(this.toSnowflake());
}