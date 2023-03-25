import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class PermissionOverwrite with ToStringHelper {
  final Snowflake id;

  final PermissionOverwriteType type;

  final Permissions allow;

  final Permissions deny;

  PermissionOverwrite({
    required this.id,
    required this.type,
    required this.allow,
    required this.deny,
  });
}

enum PermissionOverwriteType {
  role._(0),
  member._(1);

  final int value;

  const PermissionOverwriteType._(this.value);

  factory PermissionOverwriteType.parse(int value) => PermissionOverwriteType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown PermissionOverwriteType', value),
      );

  @override
  String toString() => 'PermissionOverwriteType($value)';
}
