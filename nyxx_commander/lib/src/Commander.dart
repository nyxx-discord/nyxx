part of nyxx_commander;

/// Used to determine if command can be executed in given environment.
/// Return true to allow executing command or false otherwise.
typedef PassHandlerFunction = FutureOr<bool> Function(CommandContext context);

/// Handler for executing command logic.
typedef CommandHandlerFunction = FutureOr<void> Function(CommandContext context, String message);

/// Handler for executing logic after executing command.
typedef AfterHandlerFunction = FutureOr<void> Function(CommandContext context);

/// Handler used to determine prefix for command in given environment.
/// Can be used to define different prefixes for different guild, users or dms.
/// Return String containing prefix or null if command cannot be executed.
typedef PrefixHandlerFunction = FutureOr<String?> Function(Message message);

/// Callback to customize logger output when command is executed.
typedef LoggerHandlerFunction = FutureOr<void> Function(CommandContext context, String commandName, Logger logger);

/// Callback called when command executions returns with [Exception] or [Error] ([exception] variable could be either).
typedef CommandExecutionError = FutureOr<void> Function(CommandContext context, dynamic exception);

/// Lightweight command framework. Doesn't use `dart:mirrors` and can be used in browser.
/// While constructing specify prefix which is string with prefix or
/// implement [PrefixHandlerFunction] for more fine control over where and in what conditions commands are executed.
///
/// Allows to specify callbacks which are executed before and after command - also on per command basis.
/// beforeCommandHandler callbacks are executed only command exists and is matched with message content.
// ignore: prefer_mixin
class Commander with ICommandRegistrable {
  late final PrefixHandlerFunction _prefixHandler;
  late final PassHandlerFunction? _beforeCommandHandler;
  late final AfterHandlerFunction? _afterHandlerFunction;
  late final LoggerHandlerFunction _loggerHandlerFunction;
  late final CommandExecutionError? _commandExecutionError;

  @override
  final List<CommandEntity> _commandEntities = [];

  final Logger _logger = Logger("Commander");

  /// Resolves prefix for given [message]. Returns null if there is no prefix for given [message] which
  /// means command wouldn't execute in given context.
  FutureOr<String?> getPrefixForMessage(Message message) => _prefixHandler(message);

  /// Returns unmodifiable list of registered commands.
  List<CommandEntity> get commands => List.unmodifiable(this._commandEntities);

  /// Either [prefix] or [prefixHandler] must be specified otherwise program will exit.
  /// Allows to specify additional [beforeCommandHandler] executed before main command callback,
  /// and [afterCommandHandler] executed after main command callback.
  Commander(Nyxx client,
      {String? prefix,
      PrefixHandlerFunction? prefixHandler,
      PassHandlerFunction? beforeCommandHandler,
      AfterHandlerFunction? afterCommandHandler,
      LoggerHandlerFunction? loggerHandlerFunction,
      CommandExecutionError? commandExecutionError}) {
    if (!PermissionsUtils.isApplied(client.intents, GatewayIntents.allUnprivileged)) {
      _logger.shout("Commander cannot start without at least all unprivileged intents");
      exit(1);
    }

    if (prefix == null && prefixHandler == null) {
      _logger.shout("Commander cannot start without both prefix and prefixHandler");
      exit(1);
    }

    if (prefix == null) {
      _prefixHandler = prefixHandler!;
    } else {
      _prefixHandler = (_) => prefix;
    }

    this._beforeCommandHandler = beforeCommandHandler;
    this._afterHandlerFunction = afterCommandHandler;
    this._commandExecutionError = commandExecutionError;
    this._loggerHandlerFunction = loggerHandlerFunction ?? _defaultLogger;

    client.onMessageReceived.listen(_handleMessage);

    this._logger.info("Commander ready!");
  }

  Future<void> _handleMessage(MessageReceivedEvent event) async {
    final prefix = await _prefixHandler(event.message);
    if (prefix == null) {
      return;
    }

    if (!event.message.content.startsWith(prefix)) {
      return;
    }

    // Find matching command with given message content
    final matchingCommand = _CommandMatcher._findMatchingCommand(
            event.message.content.toLowerCase().replaceFirst(prefix, "").trim().split(" "), _commandEntities)
        as CommandHandler?;

    if (matchingCommand == null) {
      return;
    }

    // Builds a RegEx that matches the full command including their parents and all possible
    // aliases of the final command entity and their parents.
    // Example: (?<finalCommand>(quote|q) (remove|rm))
    // This will match the command `quote remove`, `q remove`, `quote rm` and `q rm`

    final match = RegExp("(?<finalCommand>${matchingCommand.getFullCommandMatch().trim()})")
        .firstMatch(event.message.content.toLowerCase());
    final finalCommand = match?.namedGroup("finalCommand");

    // construct CommandContext
    final context = CommandContext._new(
      await event.message.channel.getOrDownload(),
      event.message.author,
      event.message is GuildMessage ? (event.message as GuildMessage).guild.getFromCache()! : null,
      event.message,
      "$prefix$finalCommand",
    );

    // Invoke before handler for commands
    if (!(await _invokeBeforeHandler(matchingCommand, context))) {
      return;
    }

    // Invoke before handler for commander
    if (this._beforeCommandHandler != null && !(await this._beforeCommandHandler!(context))) {
      return;
    }

    // Execute command
    try {
      await matchingCommand.commandHandler(context, event.message.content);
    } on Exception catch (e) {
      if (this._commandExecutionError != null) {
        await _commandExecutionError!(context, e);
      }
    } on Error catch (e) {
      if (this._commandExecutionError != null) {
        await _commandExecutionError!(context, e);
      }
    }

    // execute logger callback
    _loggerHandlerFunction(context, finalCommand!, this._logger);

    // invoke after handler of command
    await _invokeAfterHandler(matchingCommand, context);

    // Invoke after handler for commander
    if (this._afterHandlerFunction != null) {
      this._afterHandlerFunction!(context);
    }
  }

  // Invokes command after handler and its parents
  Future<void> _invokeAfterHandler(CommandEntity? commandEntity, CommandContext context) async {
    if (commandEntity == null) {
      return;
    }

    if (commandEntity.afterHandler != null) {
      await commandEntity.afterHandler!(context);
    }

    if (commandEntity.parent != null) {
      await _invokeAfterHandler(commandEntity.parent, context);
    }
  }

  // Invokes command before handler and its parents. It will check for next before handlers if top handler returns true.
  Future<bool> _invokeBeforeHandler(CommandEntity? commandEntity, CommandContext context) async {
    if (commandEntity == null) {
      return true;
    }

    if (commandEntity.beforeHandler == null) {
      return _invokeBeforeHandler(commandEntity.parent, context);
    }

    if (await commandEntity.beforeHandler!(context)) {
      return _invokeBeforeHandler(commandEntity.parent, context);
    }

    return false;
  }

  FutureOr<void> _defaultLogger(CommandContext ctx, String commandName, Logger logger) {
    logger.info("Command [$commandName] executed by [${ctx.author.tag}]");
  }

  /// Registers command with given [commandName]. Allows to specify command specific before and after command execution callbacks
  void registerCommand(String commandName, CommandHandlerFunction commandHandler,
      {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    this.registerCommandEntity(
        BasicCommandHandler(commandName, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler));
  }

  /// Registers command as implemented [CommandEntity] class
  void registerCommandGroup(CommandGroup commandGroup) => this.registerCommandEntity(commandGroup);
}

/// Provides common functionality for entities which can register subcommand or sub command groups.
abstract class ICommandRegistrable {
  List<CommandEntity> get _commandEntities;

  /// Registers [CommandEntity] within context of this instance. Throws error if there is command with same name as provided.
  void registerCommandEntity(CommandEntity entity) {
    if (this._commandEntities.any((element) => element.isEntityName(entity.name))) {
      throw Exception("Command name should be unique! There is already command with name: ${entity.name}}");
    }

    if (entity is CommandGroup && entity.name.isEmpty && entity.aliases.isNotEmpty) {
      throw Exception(
          "Command group cannot have aliases if its name is empty! Provided aliases: [${entity.aliases.join(", ")}]");
    }

    this._commandEntities.add(entity);
  }
}
