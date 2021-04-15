part of nyxx_interactions;

/// The type that a user should input for a [CommandOptionBuilder]
class CommandOptionType extends IEnum<int> {
  /// Specify an arg as a sub command
  static const subCommand = const CommandOptionType(1);
  /// Specify an arg as a sub command group
  static const subCommandGroup  = const CommandOptionType(2);
  /// Specify an arg as a string
  static const string = const CommandOptionType(3);
  /// Specify an arg as an int
  static const integer = const CommandOptionType(4);
  /// Specify an arg as a bool
  static const boolean = const CommandOptionType(5);
  /// Specify an arg as a user e.g @HarryET#2954
  static const user = const CommandOptionType(6);
  /// Specify an arg as a channel e.g. #Help
  static const channel = const CommandOptionType(7);
  /// Specify an arg as a role e.g. @RoleName
  static const role = const CommandOptionType(8);

  /// Create new instance of CommandArgType
  const CommandOptionType(int value) : super(value);
}

class CommandOption {
  /// The type of arg that will be later changed to an INT value, their values can be seen in the table below:
  /// | Name              | Value |
  /// |-------------------|-------|
  /// | SUB_COMMAND       | 1     |
  /// | SUB_COMMAND_GROUP | 2     |
  /// | STRING            | 3     |
  /// | INTEGER           | 4     |
  /// | BOOLEAN           | 5     |
  /// | USER              | 6     |
  /// | CHANNEL           | 7     |
  /// | ROLE              | 8     |
  late final CommandOptionType type;

  /// The name of your argument / sub-group.
  late final String name;

  /// The description of your argument / sub-group.
  late final String description;

  /// If this argument is required
  late final bool required;

  /// Choices for [CommandOptionType.string] and [CommandOptionType.string] types for the user to pick from
  late final List<ArgChoice> choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  late final List<CommandOption> options;

  CommandOption._new(Map<String, dynamic> raw) {
    this.type = CommandOptionType(raw["type"] as int);
    this.name = raw["name"] as String;
    this.description = raw["description"] as String;
    this.required = raw["required"] as bool? ?? false;

    this.choices = [
      if (raw["choices"] != null)
        for(final choiceRaw in raw["choices"])
          ArgChoice._new(choiceRaw as Map<String, dynamic>)
    ];

    this.options = [
      if (raw["options"] != null)
        for(final optionRaw in raw["options"])
          CommandOption._new(optionRaw as Map<String, dynamic>)
    ];
  }
}
