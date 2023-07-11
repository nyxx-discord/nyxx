import 'package:nyxx/src/http/managers/application_command_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class CommandPermissions with ToStringHelper {
  final ApplicationCommandManager manager;

  final Snowflake id;

  final Snowflake applicationId;

  final Snowflake guildId;

  final List<CommandPermission> permissions;

  CommandPermissions({
    required this.manager,
    required this.id,
    required this.applicationId,
    required this.guildId,
    required this.permissions,
  });

  PartialApplicationCommand? get command => id == applicationId ? null : manager.client.guilds[guildId].commands[id];

  PartialApplication get application => manager.client.applications[applicationId];

  PartialGuild get guild => manager.client.guilds[guildId];
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
