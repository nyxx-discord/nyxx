part of nyxx_interactions;

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommandBuilder implements Builder {
  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// Command description shown to the user in the Slash Command UI
  final String description;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  Snowflake? guild;

  /// The arguments that the command takes
  List<CommandOptionBuilder> options;

  SlashCommandHandlder? _handler;

  /// A slash command, can only be instantiated through a method on [Interactions]
  SlashCommandBuilder(this.name, this.description, this.options, {this.guild});

  Map<String, dynamic> _build() => {
    "name": this.name,
    "description": this.description,
    if (this.options.isNotEmpty) "options": this.options.map((e) => e._build()).toList()
  };

  void registerHandler(SlashCommandHandlder handler) => this._handler = handler;
}
