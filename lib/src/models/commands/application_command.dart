import 'package:nyxx/src/http/managers/application_command_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/commands/application_command_permissions.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// A partial [ApplicationCommand].
class PartialApplicationCommand extends WritableSnowflakeEntity<ApplicationCommand> {
  @override
  final ApplicationCommandManager manager;

  /// Create a new [PartialApplicationCommand].
  /// @nodoc
  PartialApplicationCommand({required super.id, required this.manager});

  /// Fetch the permissions for this command in a given guild.
  Future<CommandPermissions> fetchPermissions(Snowflake guildId) => manager.client.guilds[guildId].commands.fetchPermissions(id);
}

/// {@template application_command}
/// A command that can be executed by users and is displayed in the Discord client UI.
///
/// Also known as "Slash commands".
/// {@endtemplate}
class ApplicationCommand extends PartialApplicationCommand {
  /// The type of this command.
  final ApplicationCommandType type;

  /// The ID of the application this command belongs to.
  final Snowflake applicationId;

  /// The ID of the guild this command belongs to.
  final Snowflake? guildId;

  /// The name of this command.
  final String name;

  /// A map of localizations for the name of this command.
  final Map<Locale, String>? nameLocalizations;

  /// The description of this command.
  final String description;

  /// A map of localizations for the description of this command.
  final Map<Locale, String>? descriptionLocalizations;

  /// A list of options for this command if this command has a type of [ApplicationCommandType.chatInput].
  final List<CommandOption>? options;

  /// The default permissions needed to execute this command.
  final Permissions? defaultMemberPermissions;

  /// Whether this command can be ran in DMs.
  @Deprecated('Use `contexts`')
  final bool? hasDmPermission;

  /// Whether this command is NSFW.
  final bool? isNsfw;

  /// Installation context(s) where the command is available, only for globally-scoped commands. Defaults to [InteractionContextType.guildInstall].
  final List<ApplicationIntegrationType> integrationTypes;

  /// Interaction context(s) where the command can be used, only for globally-scoped commands. By default, all interaction context types included for new commands.
  final List<InteractionContextType> contexts;

  /// An auto-incrementing version number.
  final Snowflake version;

  /// {@macro application_command}
  /// @nodoc
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
    required this.integrationTypes,
    required this.contexts,
    required this.version,
  });

  /// The application this command belongs to.
  PartialApplication get application => manager.client.applications[applicationId];

  /// The guild this command belongs to.
  PartialGuild? get guild => guildId == null ? null : manager.client.guilds[guildId!];
}

/// The type of an [ApplicationCommand].
enum ApplicationCommandType {
  chatInput._(1),
  user._(2),
  message._(3);

  /// The value of this [ApplicationCommandType].
  final int value;

  const ApplicationCommandType._(this.value);

  /// Parse an [ApplicationCommandType] from an [int].
  ///
  /// The [value] must be a valid application command type.
  factory ApplicationCommandType.parse(int value) => ApplicationCommandType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown application command type', value),
      );

  @override
  String toString() => 'ApplicationCommandType($value)';
}
