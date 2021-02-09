part of nyxx_interactions;

/// The type that a user should input for a [SlashArg]
enum CommandArgType {
  SUB_COMMAND,
  SUB_COMMAND_GROUP,
  STRING,
  INTEGER,
  BOOLEAN,
  USER,
  CHANNEL,
  ROLE,
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

  /// Choices for [SlashArgType.STRING] and [SlashArgType.INTEGER] types for the user to pick from
  late final List<ArgChoice>? choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  late final List<CommandArg>? options;

  /// Used to create an argument for a [SlashCommand]. Thease are used in [Interactions.registerSlashGlobal] and [Interactions.registerSlashGuild]
  CommandArg(this.type, this.name, this.description,
      {this.defaultArg = false,
        this.required = false,
        this.choices,
        this.options});

  Map<String, dynamic> _build() {
    final subOptions = this.options != null
        ? List<Map<String, dynamic>>.generate(
        this.options!.length, (i) => this.options![i]._build())
        : null;

    final rawChoices = this.choices != null
        ? List<Map<String, dynamic>>.generate(
        this.choices!.length, (i) => this.choices![i]._build())
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
