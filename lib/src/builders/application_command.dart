import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/utils/flags.dart';

class ApplicationCommandBuilder extends CreateBuilder<ApplicationCommand> {
  String name;

  Map<Locale, String>? nameLocalizations;

  String? description;

  Map<Locale, String>? descriptionLocalizations;

  List<CommandOptionBuilder>? options;

  Flags<Permissions>? defaultMemberPermissions;

  @Deprecated('Use `contexts`')
  bool? hasDmPermission;

  ApplicationCommandType type;

  bool? isNsfw;

  /// Installation context(s) where the command is available, only for globally-scoped commands. Defaults to [ApplicationIntegrationType.guildInstall].
  List<ApplicationIntegrationType>? integrationTypes;

  /// Interaction context(s) where the command can be used, only for globally-scoped commands. By default, all interaction context types included.
  List<InteractionContextType>? contexts;

  ApplicationCommandBuilder({
    required this.name,
    required this.type,
    this.nameLocalizations,
    this.description,
    this.descriptionLocalizations,
    this.options,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  });

  ApplicationCommandBuilder.chatInput({
    required this.name,
    this.nameLocalizations,
    required String this.description,
    this.descriptionLocalizations,
    required List<CommandOptionBuilder> this.options,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  }) : type = ApplicationCommandType.chatInput;

  ApplicationCommandBuilder.message({
    required this.name,
    this.nameLocalizations,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  })  : type = ApplicationCommandType.message,
        description = null,
        descriptionLocalizations = null,
        options = null;

  ApplicationCommandBuilder.user({
    required this.name,
    this.nameLocalizations,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  })  : type = ApplicationCommandType.user,
        description = null,
        descriptionLocalizations = null,
        options = null;

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (nameLocalizations != null) 'name_localizations': {for (final MapEntry(:key, :value) in nameLocalizations!.entries) key.identifier: value},
        if (description != null) 'description': description,
        if (descriptionLocalizations != null)
          'description_localizations': {for (final MapEntry(:key, :value) in descriptionLocalizations!.entries) key.identifier: value},
        if (options != null) 'options': options!.map((e) => e.build()).toList(),
        if (defaultMemberPermissions != null) 'default_member_permissions': defaultMemberPermissions!.value.toString(),
        // ignore: deprecated_member_use_from_same_package
        if (hasDmPermission != null) 'dm_permission': hasDmPermission,
        'type': type.value,
        if (isNsfw != null) 'nsfw': isNsfw,
        if (integrationTypes != null) 'integration_types': integrationTypes!.map((type) => type.value).toList(),
        if (contexts != null) 'contexts': contexts!.map((type) => type.value).toList(),
      };
}

class ApplicationCommandUpdateBuilder extends UpdateBuilder<ApplicationCommand> {
  String? name;

  Map<Locale, String>? nameLocalizations;

  String? description;

  Map<Locale, String>? descriptionLocalizations;

  List<CommandOptionBuilder>? options;

  Flags<Permissions>? defaultMemberPermissions;

  @Deprecated('Use `contexts`')
  bool? hasDmPermission;

  bool? isNsfw;

  /// Installation context(s) where the command is available, only for globally-scoped commands. Defaults to [ApplicationIntegrationType.guildInstall].
  List<ApplicationIntegrationType>? integrationTypes;

  /// Interaction context(s) where the command can be used, only for globally-scoped commands. By default, all interaction context types included.
  List<InteractionContextType>? contexts;

  ApplicationCommandUpdateBuilder({
    this.name,
    this.nameLocalizations = sentinelMap,
    this.description,
    this.descriptionLocalizations = sentinelMap,
    this.options,
    this.defaultMemberPermissions = sentinelFlags,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  });

  ApplicationCommandUpdateBuilder.chatInput({
    required this.name,
    this.nameLocalizations = sentinelMap,
    this.description,
    this.descriptionLocalizations = sentinelMap,
    this.options,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  });

  ApplicationCommandUpdateBuilder.message({
    this.name,
    this.nameLocalizations,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  })  : description = null,
        descriptionLocalizations = null,
        options = null;

  ApplicationCommandUpdateBuilder.user({
    this.name,
    this.nameLocalizations,
    this.defaultMemberPermissions,
    this.hasDmPermission,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  })  : description = null,
        descriptionLocalizations = null,
        options = null;

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(nameLocalizations, sentinelMap)) 'name_localizations': nameLocalizations?.map((key, value) => MapEntry(key.toString(), value)),
        if (description != null) 'description': description,
        if (!identical(descriptionLocalizations, sentinelMap))
          'description_localizations': descriptionLocalizations?.map((key, value) => MapEntry(key.toString(), value)),
        if (options != null) 'options': options!.map((e) => e.build()).toList(),
        if (!identical(defaultMemberPermissions, sentinelFlags)) 'default_member_permissions': defaultMemberPermissions?.value.toString(),
        // ignore: deprecated_member_use_from_same_package
        if (hasDmPermission != null) 'dm_permission': hasDmPermission,
        if (isNsfw != null) 'nsfw': isNsfw,
        if (integrationTypes != null) 'integration_types': integrationTypes!.map((type) => type.value).toList(),
        if (contexts != null) 'contexts': contexts!.map((type) => type.value).toList(),
      };
}

class CommandOptionBuilder extends CreateBuilder<CommandOption> {
  CommandOptionType type;

  String name;

  Map<Locale, String>? nameLocalizations;

  String description;

  Map<Locale, String>? descriptionLocalizations;

  bool? isRequired;

  List<CommandOptionChoiceBuilder<dynamic>>? choices;

  List<CommandOptionBuilder>? options;

  List<ChannelType>? channelTypes;

  num? minValue;

  num? maxValue;

  int? minLength;

  int? maxLength;

  bool? hasAutocomplete;

  CommandOptionBuilder({
    required this.type,
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
    this.choices,
    this.options,
    this.channelTypes,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.hasAutocomplete,
  });

  CommandOptionBuilder.subCommand({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    required List<CommandOptionBuilder> this.options,
  })  : type = CommandOptionType.subCommand,
        isRequired = null,
        choices = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.subCommandGroup({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    required List<CommandOptionBuilder> this.options,
  })  : type = CommandOptionType.subCommandGroup,
        isRequired = null,
        choices = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.string({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
    List<CommandOptionChoiceBuilder<String>>? this.choices,
    this.minLength,
    this.maxLength,
    this.hasAutocomplete,
  })  : type = CommandOptionType.string,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null;

  CommandOptionBuilder.integer({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
    List<CommandOptionChoiceBuilder<int>>? this.choices,
    int? this.minValue,
    int? this.maxValue,
    this.hasAutocomplete,
  })  : type = CommandOptionType.integer,
        options = null,
        channelTypes = null,
        minLength = null,
        maxLength = null;

  CommandOptionBuilder.boolean({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
  })  : type = CommandOptionType.boolean,
        choices = null,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.user({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
  })  : type = CommandOptionType.user,
        choices = null,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.channel({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
    this.channelTypes,
  })  : type = CommandOptionType.channel,
        choices = null,
        options = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.role({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
  })  : type = CommandOptionType.role,
        choices = null,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.mentionable({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
  })  : type = CommandOptionType.mentionable,
        choices = null,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  CommandOptionBuilder.number({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
    List<CommandOptionChoiceBuilder<double>>? this.choices,
    double? this.minValue,
    double? this.maxValue,
    this.hasAutocomplete,
  })  : type = CommandOptionType.number,
        options = null,
        channelTypes = null,
        minLength = null,
        maxLength = null;

  CommandOptionBuilder.attachment({
    required this.name,
    this.nameLocalizations,
    required this.description,
    this.descriptionLocalizations,
    this.isRequired,
  })  : type = CommandOptionType.attachment,
        choices = null,
        options = null,
        channelTypes = null,
        minValue = null,
        maxValue = null,
        minLength = null,
        maxLength = null,
        hasAutocomplete = null;

  @override
  Map<String, Object?> build() => {
        'type': type.value,
        'name': name,
        if (nameLocalizations != null) 'name_localizations': {for (final MapEntry(:key, :value) in nameLocalizations!.entries) key.identifier: value},
        'description': description,
        if (descriptionLocalizations != null)
          'description_localizations': {for (final MapEntry(:key, :value) in descriptionLocalizations!.entries) key.identifier: value},
        if (isRequired != null) 'required': isRequired,
        if (choices != null) 'choices': choices!.map((e) => e.build()).toList(),
        if (options != null) 'options': options!.map((e) => e.build()).toList(),
        if (channelTypes != null) 'channel_types': channelTypes!.map((e) => e.value).toList(),
        if (minValue != null) 'min_value': minValue,
        if (maxValue != null) 'max_value': maxValue,
        if (minLength != null) 'min_length': minLength,
        if (maxLength != null) 'max_length': maxLength,
        if (hasAutocomplete != null) 'autocomplete': hasAutocomplete,
      };
}

class CommandOptionChoiceBuilder<T> extends CreateBuilder<CommandOptionChoice> {
  String name;

  Map<Locale, String>? nameLocalizations;

  T value;

  CommandOptionChoiceBuilder({required this.name, this.nameLocalizations, required this.value});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (nameLocalizations != null) 'name_localizations': {for (final MapEntry(:key, :value) in nameLocalizations!.entries) key.identifier: value},
        'value': value,
      };
}
