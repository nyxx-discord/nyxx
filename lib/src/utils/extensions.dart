import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';

/// Extension on int
extension IntExtensions on int {
  /// Converts int to [Snowflake]
  Snowflake toSnowflake() => Snowflake(this);

  /// Converts int to [SnowflakeEntity]
  SnowflakeEntity toSnowflakeEntity() => SnowflakeEntity(toSnowflake());
}

/// Extension on int
extension StringExtensions on String {
  /// Converts String to [Snowflake]
  Snowflake toSnowflake() => Snowflake(this);

  /// Converts String to [SnowflakeEntity]
  SnowflakeEntity toSnowflakeEntity() => SnowflakeEntity(toSnowflake());
}

/// Extensions on Iterable of Snowflakes entities
extension SnowflakeEntityListExtensions on Iterable<SnowflakeEntity> {
  /// Returns Iterable of [SnowflakeEntity] as Iterable of IDs
  Iterable<Snowflake> asSnowflakes() => map((e) => e.id);
}
