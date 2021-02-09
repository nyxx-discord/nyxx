part of nyxx;

/// Thrown when cannot convert provided data to [Snowflake]
class InvalidSnowflakeException implements Exception {
  final dynamic _invalidSnowflake;

  InvalidSnowflakeException._new(this._invalidSnowflake);

  @override
  String toString() => "InvalidSnowflakeException: Cannot parse [$_invalidSnowflake] to Snowflake";
}
