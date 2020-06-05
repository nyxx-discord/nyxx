part of nyxx.commander;

/// Used to determine if command can be executed in given environment.
/// Return true to allow executing command or false otherwise.
typedef PassHandlerFunction = FutureOr<bool> Function(CommandContext context, String message);

/// Handler for executing command logic.
typedef CommandHandlerFunction = FutureOr<void> Function(CommandContext context, String message);

/// Handler used to determine prefix for command in given environment.
/// Can be used to define different prefixes for different guild, users or dms.
/// Return String containing prefix or null if command cannot be executed.
typedef PrefixHandlerFunction = FutureOr<String?> Function(Message message);

/// Callback to customize logger output when command is executed.
typedef LoggerHandlerFunction = FutureOr<void> Function(CommandContext context, String commandName, Logger logger);

/// Lightweight command framework. Doesn't use `dart:mirrors` and can be used in browser.
/// While constructing specify prefix which is string with prefix or
/// implement [PrefixHandlerFunction] for more fine control over where and in what conditions commands are executed.
///
/// Allows to specify callbacks which are executed before and after command - also on per command basis.
/// [beforeCommandHandler] callbacks are executed only command exists and is matched with message content.
class Commander {
  late final PrefixHandlerFunction _prefixHandler;
  late final PassHandlerFunction? _beforeCommandHandler;
  late final CommandHandlerFunction? _afterHandlerFunction;
  late final LoggerHandlerFunction _loggerHandlerFunction;

  final List<CommandHandler> _commands = [];

  final Logger _logger = Logger("Commander");

  /// Either [prefix] or [prefixHandler] must be specified otherwise program will exit.
  /// Allows to specify additional [beforeCommandHandler] executed before main command callback,
  /// and [afterCommandHandler] executed after main command callback.
  Commander(Nyxx client,
      {String? prefix,
      PrefixHandlerFunction? prefixHandler,
      PassHandlerFunction? beforeCommandHandler,
      CommandHandlerFunction? afterCommandHandler,
      LoggerHandlerFunction? loggerHandlerFunction}) {
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

    this._loggerHandlerFunction = loggerHandlerFunction ?? _defaultLogger;

    client.onMessageReceived.listen(_handleMessage);

    this._logger.info("Commander ready!");
  }

  FutureOr<void> _defaultLogger(CommandContext ctx, String commandName, Logger logger) {
    logger.info("Command [$commandName] executed by [${ctx.author!.tag}]");
  }

  Future<void> _handleMessage(MessageReceivedEvent event) async {
    final prefix = await _prefixHandler(event.message);
    if (prefix == null) {
      return;
    }

    // TODO: NNBD: try-catch in where
    CommandHandler? matchingCommand;
    try {
      matchingCommand = _commands.firstWhere(
          (element) => _isCommandMatching(element.commandName, event.message.content.replaceFirst(prefix, "")));
    } on Error {
      return;
    }

    /// TODO: Cache
    final context = CommandContext._new(event.message.channel, event.message.author,
        event.message is GuildMessage ? (event.message as GuildMessage).guild : null, event.message, "$prefix${matchingCommand.commandName}");

    if (this._beforeCommandHandler != null && !await this._beforeCommandHandler!(context, event.message.content)) {
      return;
    }

    if (matchingCommand.beforeHandler != null &&
        !await matchingCommand.beforeHandler!(context, event.message.content)) {
      return;
    }

    await matchingCommand.commandHandler(context, event.message.content);

    // execute logger callback
    _loggerHandlerFunction(context, matchingCommand.commandName, this._logger);

    if (matchingCommand.afterHandler != null) {
      await matchingCommand.afterHandler!(context, event.message.content);
    }

    if (this._afterHandlerFunction != null) {
      this._afterHandlerFunction!(context, event.message.content);
    }
  }

  /// Registers command with given [commandName]. Allows to specify command specific before and after command execution callbacks
  void registerCommand(String commandName, CommandHandlerFunction commandHandler,
      {PassHandlerFunction? beforeHandler, CommandHandlerFunction? afterHandler}) {
    this._commands.add(
        _InternalCommandHandler(commandName, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler));

    // TODO: That is not most efficient way
    this._commands.sort((a, b) => -a.commandName.length.compareTo(b.commandName.length));
  }

  /// Registers command as implemented [CommandHandler] class
  void registerCommandClass(CommandHandler commandHandler) => this._commands.add(commandHandler);
}
