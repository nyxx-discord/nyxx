part of nyxx_interactions;

typedef SlashCommandHandlder = FutureOr<void> Function(InteractionEvent);

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions {
  static const _interactionCreateCommand = "INTERACTION_CREATE";
  static const _op0 = 0;

  late final Nyxx _client;
  final Logger _logger = Logger("Interactions");
  final List<SlashCommand> _commands = [];
  late final _EventController _events;

  /// Emitted when a slash command is sent.
  late final Stream<InteractionEvent> onSlashCommand;

  /// Emitted when a slash command is created by the user.
  late final Stream<SlashCommand> onSlashCommandCreated;

  final _commandHandlers = <String, SlashCommandHandlder>{};

  /// Create new instance of the interactions class.
  Interactions(Nyxx client) {
    this._client = client;
    _events = _EventController(this);
    _client.options.dispatchRawShardEvent = true;
    _logger.info("Interactions ready");

    client.onReady.listen((event) async {
      client.shardManager.rawEvent.listen((event) {
        if (event.rawData["op"] as int == _op0) {
          if (event.rawData["t"] as String == _interactionCreateCommand) {
            _events.onSlashCommand.add(
              InteractionEvent._new(client, event.rawData["d"] as Map<String, dynamic>),
            );
          }
        }
      });

      if (this._commandHandlers.isNotEmpty) {
        await this.sync();
        this.onSlashCommand.listen((event) async {
          try {
            final handler = _commandHandlers[event.interaction.name];

            if (handler == null) {
              return;
            }

            await handler(event);
          } on Error catch (e) {
            this._logger.severe("Failed to execute command (${event.interaction.name})", e);
          }
        });
      }
    });
  }

  /// Registers command and handler for that command.
  void registerHandler(String name, String description, List<CommandArg> args, {required SlashCommandHandlder handler, Snowflake? guild}) {
    final command = this.createCommand(name, description, args, guild: guild);
    this.registerCommand(command);
    _commandHandlers[name] = handler;
  }

  /// Creates a command that can be registered using .registerCommand or .registerCommands
  ///
  /// The [name] is the name that the user can see when typing /, the [description] can also be seen in this same place. [args] are any arguments you want the user to type, you can put an empty list here is you require no arguments. If you want this to be specific to a guild you can set the [guild] param with the ID of a guild, when testing its recommended to use this as it propagates immediately while global commands can take some time.
  SlashCommand createCommand(String name, String description, List<CommandArg> args, {Snowflake? guild}) =>
      SlashCommand._new(_client, name, description, args,
          guild: guild != null ? CacheUtility.createCacheableGuild(_client, guild) : null);

  /// Registers a single command.
  ///
  /// The command you want to register is the [command] you create a command by using [createCommand]
  void registerCommand(SlashCommand command) => _commands.add(command);

  /// Registers multiple commands at one.
  ///
  /// The commands you want to register is the [commands] you create a command by using [createCommand], this just runs [registerCommand] for each command.
  void registerCommands(List<SlashCommand> commands) => commands.forEach(this.registerCommand);

  /// Gets all the commands that are currently registered.
  List<SlashCommand> getCommands({bool registeredOnly = false}) {
    if (!registeredOnly) {
      return _commands;
    }

    return _commands.where((command) => command.isRegistered).toList();
  }

  /// Syncs the local commands with the discord API
  Future<void> sync() async {
    var success = 0;
    var failed = 0;
    for (final command in _commands) {
      if (!command.isRegistered) {
        try {
          final registeredCommand = await command._register();
          this._events.onSlashCommandCreated.add(registeredCommand);

          success++;
        } on HttpResponseError catch (e) {
          this._logger.severe("Failed registering command: ${e.toString()}");
          failed++;
        }
      }
    }
    _logger.info(
        "Successfully registered $success ${success > 1 ? "commands" : "command"}. Failed registering $failed ${failed > 1 ? "commands" : "command"}.");
  }
}
