import 'dart:mirrors';

import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/to_string_helper/mirrors_impl.dart';

/// Internal mixin containing a basic implementation of methods for [ManagedSnowflakeEntity]s.
///
/// This is as a separate mixin to give us access to the type of the actual object `T` which is used
/// in [operator==] and [toString].
mixin SnowflakeEntityMixin<T extends ManagedSnowflakeEntity<T>> on ManagedSnowflakeEntity<T> {
  @override
  String toString() => stringifyInstance(reflect(this), T.toString());
}
