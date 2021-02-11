part of nyxx_interactions;

/// The type that a user should input for a [SlashArg]
enum CommandArgType {
  /// Specify an arg as a sub command
  subCommand,
  /// Specify an arg as a sub command group
  subCommandGroup,
  /// Specify an arg as a string
  string,
  /// Specify an arg as an int
  integer,
  /// Specify an arg as a bool
  boolean,
  /// Specify an arg as a user e.g @HarryET#2954
  user,
  /// Specify an arg as a channel e.g. #Help
  channel,
  /// Specify an arg as a role e.g. @RoleName
  role,
}

/// An argument for a [SlashCommand].
class CommandArg {
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
  late final CommandArgType type;

  /// The name of your argument / sub-group.
  late final String name;

  /// The description of your argument / sub-group.
  late final String description;

  /// If this should be the fist required option the user picks
  late final bool defaultArg;

  /// If this argument is required
  late final bool required;

  /// Choices for [CommandArgType.string] and [CommandArgType.string] types for the user to pick from
  late final List<ArgChoice>? choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  late final List<CommandArg>? options;

  /// Used to create an argument for a [SlashCommand]. Tease are used in [Interactions.registerCommand]
  CommandArg(this.type, this.name, this.description,
      {this.defaultArg = false, this.required = false, this.choices, this.options});

  Map<String, dynamic> _build() {
    final subOptions = this.options != null
        ? this.options!.map((e) => e._build())
        : null;

    final rawChoices = this.choices != null
        ? this.choices!.map((e) => e._build())
        : null;

    return {
      "type": (this.type.index) + 1,
      "name": this.name,
      "description": this.description,
      "default": this.defaultArg,
      "required": this.required,
      "choices": rawChoices,
      "options": subOptions
    };
  }
}
