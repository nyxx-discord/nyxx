import 'package:nyxx/src/http/managers/application_command_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template command_permissions}
/// The permissions for an [ApplicationCommand] in a guild.
/// {@endtemplate}
class CommandPermissions extends SnowflakeEntity<CommandPermissions> {
  /// The manager for this [CommandPermissions].
  final GuildApplicationCommandManager manager;

  /// The ID of the application these permissions apply to.
  final Snowflake applicationId;

  /// The ID of the guild these permissions apply in.
  final Snowflake guildId;

  /// A list of specific permissions.
  final List<CommandPermission> permissions;

  /// {@macro command_permissions}
  /// @nodoc
  CommandPermissions({
    required this.manager,
    required super.id,
    required this.applicationId,
    required this.guildId,
    required this.permissions,
  });

  /// The command these permissions apply to, or `null` if these permissions apply to the entire application.
  PartialApplicationCommand? get command => id == applicationId ? null : manager.client.guilds[guildId].commands[id];

  /// The application these permissions apply to.
  PartialApplication get application => manager.client.applications[applicationId];

  /// The guild these permissions apply in.
  PartialGuild get guild => manager.client.guilds[guildId];

  @override
  Future<CommandPermissions> fetch() async {
    if (command != null) {
      return await command!.fetchPermissions(guildId);
    }

    final permissions = await guild.commands.listPermissions();
    return permissions.firstWhere((element) => element.id == id);
  }

  @override
  Future<CommandPermissions> get() async => manager.permissionsCache[id] ?? await fetch();
}

/// {@template command_permission}
/// The permission for a role, user or channel to use an [ApplicationCommand].
/// {@endtemplate}
class CommandPermission with ToStringHelper {
  /// The ID of the target entity.
  final Snowflake id;

  /// The type of entity.
  final CommandPermissionType type;

  /// Whether the entity has the permission to use the command.
  final bool hasPermission;

  /// {@macro command_permission}
  /// @nodoc
  CommandPermission({required this.id, required this.type, required this.hasPermission});
}

/// The type of a [CommandPermission].
enum CommandPermissionType {
  role._(1),
  user._(2),
  channel._(3);

  /// The value of this [CommandPermissionType].
  final int value;

  const CommandPermissionType._(this.value);

  /// Parse a [CommandPermissionType] from an [int].
  ///
  /// The [value] must be a valid command permission type.
  factory CommandPermissionType.parse(int value) => CommandPermissionType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown command permission type', value),
      );

  @override
  String toString() => 'CommandPermissionType($value)';
}
