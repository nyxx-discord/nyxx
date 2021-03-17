part of nyxx_interactions;

/// The type that a user should input for a [CommandArg]
class CommandArgType extends IEnum<int> {
  /// Specify an arg as a sub command
  static const subCommand = const CommandArgType(1);
  /// Specify an arg as a sub command group
  static const subCommandGroup  = const CommandArgType(2);
  /// Specify an arg as a string
  static const string = const CommandArgType(3);
  /// Specify an arg as an int
  static const integer = const CommandArgType(4);
  /// Specify an arg as a bool
  static const boolean = const CommandArgType(5);
  /// Specify an arg as a user e.g @HarryET#2954
  static const user = const CommandArgType(6);
  /// Specify an arg as a channel e.g. #Help
  static const channel = const CommandArgType(7);
  /// Specify an arg as a role e.g. @RoleName
  static const role = const CommandArgType(8);

  /// Create new instance of CommandArgType
  const CommandArgType(int value) : super(value);
}

/// An argument for a [SlashCommand].
class CommandArg implements Builder {
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

  Map<String, dynamic> _build() => {
      "type": this.type.value,
      "name": this.name,
      "description": this.description,
      "default": this.defaultArg,
      "required": this.required,
      if (this.choices != null) "choices": this.choices!.map((e) => e._build()).toList(),
      if (this.options != null) "options": this.options!.map((e) => e._build()).toList()
    };
}
