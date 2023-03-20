import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// Internal mixin containing a basic implementation of methods for [SnowflakeEntity]s.
///
/// This is as a separate mixin to give us access to the type of the actual object `T` which is used
/// in [operator==] and [toString].
mixin SnowflakeEntityMixin<T extends SnowflakeEntity<T>> on SnowflakeEntity<T> {
  @override
  bool operator ==(Object other) => identical(this, other) || (other is T && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$T($id)';
}
