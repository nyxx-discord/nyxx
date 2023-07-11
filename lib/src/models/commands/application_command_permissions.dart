import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class CommandPermissions with ToStringHelper {
  final Snowflake id;

  final Snowflake applicationId;

  final Snowflake guildId;

  final List<CommandPermission> permissions;

  CommandPermissions({
    required this.id,
    required this.applicationId,
    required this.guildId,
    required this.permissions,
  });
}

class CommandPermission with ToStringHelper {
  final Snowflake id;

  final CommandPermissionType type;

  final bool hasPermission;

  CommandPermission({required this.id, required this.type, required this.hasPermission});
}

enum CommandPermissionType {
  role._(1),
  user._(2),
  channel._(3);

  final int value;

  const CommandPermissionType._(this.value);

  factory CommandPermissionType.parse(int value) => CommandPermissionType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown command permission type', value),
      );

  @override
  String toString() => 'CommandPermissionType($value)';
}
