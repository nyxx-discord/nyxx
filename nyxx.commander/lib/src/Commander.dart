part of nyxx.commander;

typedef Future<bool> PassHandlerFunction(CommandContext context, String message);
typedef Future<void> CommandHandlerFunction(CommandContext context, String message);
typedef Future<String?> PrefixHandlerFunction(CommandContext context, String message);

class Commander {
  late final PrefixHandlerFunction _prefixHandler;
  late final PassHandlerFunction? _beforeComamndHandler;
  late final CommandHandlerFunction? _afterHandlerFunction;

  List<CommandHandler> commands = [];
  
  Logger _logger = Logger.detached("Commander");

  Commander(Nyxx client, {String? prefix, PrefixHandlerFunction? prefixHandler, PassHandlerFunction? beforeCommandHandler, CommandHandlerFunction? afterCommandHandler}) {
    if(prefix == null && prefixHandler == null) {
      _logger.shout("Commander cannot start without both prefix and prefixHandler");
      exit(1);
    }

    if(prefix == null) {
      _prefixHandler = prefixHandler!;
    } else {
      _prefixHandler = (ctx, msg) async => msg.startsWith(prefix) ? prefix : null;
    }

    this._beforeComamndHandler = beforeCommandHandler;
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

    CommandHandler? matchingCommand = commands.firstWhere((element) => _isCommandMatching(
        element.commandName, event.message!.content.replaceFirst(prefix, "")), orElse: () => null);

    if(matchingCommand == null) {
      return;
    }

    if(this._beforeComamndHandler != null && !await this._beforeComamndHandler!(context, event.message!.content)) {
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

  void registerCommand(String commandName, CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, CommandHandlerFunction? afterHandler}) {
    this.commands.add(_InternalCommandHandler(commandName, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler));
  }

  void registerCommandClass(CommandHandler commandHandler) => this.commands.add(commandHandler);
}