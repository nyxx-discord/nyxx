part of nyxx.commander;

/// Used to determine if command can be executed in given environment.
/// Return true to allow executing command or false otherwise.
typedef Future<bool> PassHandlerFunction(CommandContext context, String message);

/// Handler for executing command logic.
typedef Future<void> CommandHandlerFunction(CommandContext context, String message);

/// Handler used to determine prefix for command in given environment.
/// Can be used to define different prefixes for different guild, users or dms.
/// Return String containing prefix or null if command cannot be executed.
typedef Future<String?> PrefixHandlerFunction(CommandContext context, String message);

/// Lightweight command framework. Doesn't use `dart:mirrors` and can be used in browser.
/// While constructing specify prefix which is string with prefix or 
/// implement [PrefixHandlerFunction] for more fine control over where and in what conditions commands are executed.
/// 
/// Allows to specify callbacks which are executed before and after command - also on per command basis.
/// [BeforeHandlerFunction] callbacks are executed only command exists and is matched with message content.
class Commander {
  late final PrefixHandlerFunction _prefixHandler;
  late final PassHandlerFunction? _beforeComandHandler;
  late final CommandHandlerFunction? _afterHandlerFunction;

  List<CommandHandler> _commands = [];
  
  Logger _logger = Logger.detached("Commander");

  /// Either [prefix] or [prefixHandler] must be specified otherwise program will exit.
  /// Allows to specify additional [beforeCommandHandler] executed before main command callback,
  /// and [afterCommandCallback] executed after main command callback.
  Commander(Nyxx client, {String? prefix, PrefixHandlerFunction? prefixHandler, PassHandlerFunction? beforeCommandHandler, CommandHandlerFunction? afterCommandHandler}) {
    if(prefix == null && prefixHandler == null) {
      _logger.shout("Commander cannot start without both prefix and prefixHandler");
      exit(1);
    }

    if(prefix == null) {
      _prefixHandler = prefixHandler!;
    } else {
      _prefixHandler = (ctx, msg) async => prefix;
    }

    this._beforeComandHandler = beforeCommandHandler;
    this._afterHandlerFunction = afterCommandHandler;

    client.onMessageReceived.listen(_handleMessage);
  }

  Future<void> _handleMessage(MessageReceivedEvent event) async {
    if(event.message == null) {
      return;
    }

    var context = CommandContext._new(event.message!.channel,
        event.message!.author, event.message!.guild, event.message!);

    var prefix = await _prefixHandler(context, event.message!.content);
    if(prefix == null) {
      return;
    }

    CommandHandler? matchingCommand = _commands.firstWhere((element) => _isCommandMatching(
        element.commandName, event.message!.content.replaceFirst(prefix, "")), orElse: () => null);

    if(matchingCommand == null) {
      return;
    }

    if(this._beforeComandHandler != null && !await this._beforeComandHandler!(context, event.message!.content)) {
      return;
    }

    if(matchingCommand.beforeHandler != null && !await matchingCommand.beforeHandler!(context, event.message!.content)){
      return;
    }

    await matchingCommand.commandHandler(context, event.message!.content);

    if(matchingCommand.afterHandler != null) {
      await matchingCommand.afterHandler!(context, event.message!.content);
    }

    if(this._afterHandlerFunction != null) {
      this._afterHandlerFunction!(context, event.message!.content);
    }
  }

  /// Registers command with given [commandName]. Allows to specify command specific before and after command execution callbacks
  void registerCommand(String commandName, CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, CommandHandlerFunction? afterHandler}) {
    this._commands.add(_InternalCommandHandler(commandName, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler));
  }

  /// Registers command as implemented [CommandHandler] class
  void registerCommandClass(CommandHandler commandHandler) => this._commands.add(commandHandler);
}