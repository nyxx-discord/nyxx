import 'package:nyxx/src/core/Snowflake.dart';

/// Thrown when cannot convert provided data to [Snowflake]
class InvalidSnowflakeException implements Exception {
  final dynamic _invalidSnowflake;

  /// Creates an instance of [InvalidSnowflakeException]
  InvalidSnowflakeException(this._invalidSnowflake);

  @override
  String toString() => "InvalidSnowflakeException: Cannot parse [$_invalidSnowflake] to Snowflake";
}
