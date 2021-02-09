part of nyxx_interactions;

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions {
  late final Nyxx _client;
  final Logger _logger = Logger("Interactions");
  final List<SlashCommand> _commands = List.empty(growable: true);
  late final _EventController _events;

  /// Emitted when a a slash command is sent.
  late Stream<InteractionEvent> onSlashCommand;

  /// Emitted when a a slash command is sent.
  late Stream<SlashCommand> onSlashCommandCreated;

  ///
  Interactions(Nyxx client) {
    this._client = client;
    _events = _EventController(this);
    _client.options.dispatchRawShardEvent = true;
    _logger.info("Interactions ready");

    client.onReady.listen((event) {
      client.shardManager.rawEvent.listen((event) {
        print(event.rawData);
        if (event.rawData["op"] as int == 0) {
          if (event.rawData["t"] as String == "INTERACTION_CREATE") {
            _events.onSlashCommand.add(
              InteractionEvent._new(
                  client, event.rawData["d"] as Map<String, dynamic>),
            );
          }
        }
      });
    });
  }

  SlashCommand createCommand(String name, String description, List<CommandArg> args, {String? guild})
    => SlashCommand._new(_client, name, description, args, guild: guild != null ? CacheUtility.createCacheableGuild(_client, Snowflake(guild)) : null);

  /// Registers a single command.
  ///
  /// @param command A [SlashCommand] to register.
  void registerCommand(SlashCommand command) {
    _commands.add(command);
  }

  /// Registers multiple commands at one.
  ///
  /// This wraps around [Interactions.registerCommand()] running [Interactions.registerCommand] for each command in the list.
  /// @param commands A list of [SlashCommand]s to register.
  void registerCommands(List<SlashCommand> commands) {
    for(var i = 0; i < commands.length; i++) {
      this.registerCommand(commands[i]);
    }
  }

  List<SlashCommand> getCommands({bool registeredOnly = false}) {
    if(!registeredOnly) { return _commands; }
    final registeredCommands = List<SlashCommand>.empty(growable: true);
    for(var i = 0; i < _commands.length; i++) {
      final el = _commands[i];
      if(el.isRegistered) {
        registeredCommands.add(el);
      }
    }
    return registeredCommands;
  }

  Future<void> sync() async {
    var success = 0;
    var failed = 0;
    for(var i = 0; i < _commands.length; i++) {
      final el = _commands[i];
      if(!el.isRegistered) {
        final command = await el._register();
        if(command != null) {
          _commands[i] = command;
          this._events.onSlashCommandCreated.add(_commands[i]);
          success++;
        } else {
          failed++;
        }
      }
    }
    _logger.info("Successfully registered $success ${success > 1 ? "commands" : "command"}. Failed registering $failed ${failed > 1 ? "commands" : "command"}.");
  }

}
