part of nyxx_interactions;

/// An argument for a [SlashCommandBuilder].
class CommandOptionBuilder extends Builder {
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
  final CommandOptionType type;

  /// The name of your argument / sub-group.
  final String name;

  /// The description of your argument / sub-group.
  final String description;

  /// If this should be the fist required option the user picks
  bool defaultArg = false;

  /// If this argument is required
  bool required = false;

  /// Choices for [CommandOptionType.string] and [CommandOptionType.string] types for the user to pick from
  List<ArgChoiceBuilder>? choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  List<CommandOptionBuilder>? options;

  SlashCommandHandler? _handler;

  /// Used to create an argument for a [SlashCommandBuilder].
  CommandOptionBuilder(this.type, this.name, this.description,
      {this.defaultArg = false, this.required = false, this.choices, this.options});

  Map<String, dynamic> build() => {
    "type": this.type.value,
    "name": this.name,
    "description": this.description,
    "default": this.defaultArg,
    "required": this.required,
    if (this.choices != null) "choices": this.choices!.map((e) => e.build()).toList(),
    if (this.options != null) "options": this.options!.map((e) => e.build()).toList()
  };

  /// Registers handler for subcommand
  void registerHandler(SlashCommandHandler handler) {
    if (this.type != CommandOptionType.subCommand) {
      throw StateError("Cannot register handler for command option with type other that subcommand");
    }

    this._handler = handler;
  }
}
