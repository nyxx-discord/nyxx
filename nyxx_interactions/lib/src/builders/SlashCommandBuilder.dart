part of nyxx_interactions;

class SlashCommandTarget extends IEnum<int> {
  static const SlashCommandTarget chat = const SlashCommandTarget(1);
  static const SlashCommandTarget user = const SlashCommandTarget(2);
  static const SlashCommandTarget message = const SlashCommandTarget(3);

  const SlashCommandTarget(int value) : super(value);
}

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommandBuilder extends Builder {
  /// The commands ID that is defined on registration and used for permission syncing.
  late final Snowflake _id;

  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// Command description shown to the user in the Slash Command UI
  final String? description;

  /// If people can use the command by default or if they need permissions to use it.
  final bool defaultPermissions;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  Snowflake? guild;

  /// The arguments that the command takes
  List<CommandOptionBuilder> options;

  /// Permission overrides for the command
  List<ICommandPermissionBuilder>? permissions;

  /// Target of slash command if different that SlashCommandTarget.chat - slash command will
  /// become context menu in appropriate context
  SlashCommandTarget target;

  /// Handler for SlashCommandBuilder
  SlashCommandHandler? _handler;

  /// A slash command, can only be instantiated through a method on [Interactions]
  SlashCommandBuilder(this.name, this.description, this.options,
      {this.defaultPermissions = true, this.permissions, this.guild, this.target = SlashCommandTarget.chat}) {
    if (!slashCommandNameRegex.hasMatch(this.name)) {
      throw ArgumentError(
          "Command name has to match regex: ${slashCommandNameRegex.pattern}");
    }
  }

  @override
  RawApiMap build() => {
        "name": this.name,
        if (this.target == SlashCommandTarget.chat)
          "description": this.description,
        "default_permission": this.defaultPermissions,
        if (this.options.isNotEmpty)
          "options": this.options.map((e) => e.build()).toList(),
        "type": this.target.value,
      };

  void _setId(Snowflake id) => this._id = id;

  /// Register a permission
  void addPermission(ICommandPermissionBuilder permission) {
    if(this.permissions == null) {
      this.permissions = [];
    }
    this.permissions!.add(permission);
  }

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
