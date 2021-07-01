part of nyxx_interactions;

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommandBuilder extends Builder {

  /// The commands ID that is defined on registration and used for permission syncing.
  late final Snowflake _id;

  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// Command description shown to the user in the Slash Command UI
  final String description;

  /// If people can use the command by default or if they need permissions to use it.
  final bool defaultPermisions;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  Snowflake? guild;

  /// The arguments that the command takes
  List<CommandOptionBuilder> options;

  /// Permission overrides for the command
  final List<CommandPermissionBuilder> permissions = [];

  /// Handler for SlashCommandBuilder
  SlashCommandHandler? _handler;

  /// A slash command, can only be instantiated through a method on [Interactions]
  SlashCommandBuilder(this.name, this.description, this.options,
      {this.defaultPermisions = true, this.guild}) {
    if (!slashCommandNameRegex.hasMatch(this.name)) {
      throw ArgumentError(
          "Command name has to match regex: ${slashCommandNameRegex.pattern}");
    }
  }

  @override
  RawApiMap build() => {
        "name": this.name,
        "description": this.description,
        "default_permission": this.defaultPermisions,
        if (this.options.isNotEmpty)
          "options": this.options.map((e) => e.build()).toList()
      };

  void _setId(Snowflake id) => this._id = id;

  /// Register a permission
  void addPermission(CommandPermissionBuilder permission) =>
      this.permissions.add(permission);

  /// Registers handler for command. Note command cannot have handler if there are options present
  void registerHandler(SlashCommandHandler handler) {
    if (this.options.any((element) =>
        element.type == CommandOptionType.subCommand ||
        element.type == CommandOptionType.subCommandGroup)) {
      throw new ArgumentError(
          "Cannot register handler for slash command if command have subcommand or subcommandgroup");
    }

    this._handler = handler;
  }
}
