import 'package:nyxx/src/http/managers/application_command_manager.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

class PartialApplicationCommand extends WritableSnowflakeEntity<ApplicationCommand> {
  @override
  final ApplicationCommandManager manager;

  PartialApplicationCommand({required super.id, required this.manager});
}

class ApplicationCommand extends PartialApplicationCommand {
  final ApplicationCommandType type;

  final Snowflake applicationId;

  final Snowflake? guildId;

  final String name;

  final Map<Locale, String>? nameLocalizations;

  final String description;

  final Map<Locale, String>? descriptionLocalizations;

  final List<CommandOption>? options;

  final Permissions? defaultMemberPermissions;

  final bool? hasDmPermission;

  final bool? isNsfw;

  final Snowflake version;

  ApplicationCommand({
    required super.id,
    required super.manager,
    required this.type,
    required this.applicationId,
    required this.guildId,
    required this.name,
    required this.nameLocalizations,
    required this.description,
    required this.descriptionLocalizations,
    required this.options,
    required this.defaultMemberPermissions,
    required this.hasDmPermission,
    required this.isNsfw,
    required this.version,
  });
}

enum ApplicationCommandType {
  chatInput._(1),
  user._(2),
  message._(3);

  final int value;

  const ApplicationCommandType._(this.value);

  factory ApplicationCommandType.parse(int value) => ApplicationCommandType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown application command type', value),
      );

  @override
  String toString() => 'ApplicationCommandType($value)';
}
