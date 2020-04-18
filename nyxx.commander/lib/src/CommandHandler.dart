part of nyxx.commander;

abstract class CommandHandler {
  PassHandlerFunction? get beforeHandler => null;
  CommandHandlerFunction? get afterHandler => null;
  CommandHandlerFunction get commandHandler;

  String get commandName;
}

class _InternalCommandHandler implements CommandHandler {
  @override
  final PassHandlerFunction? beforeHandler;

  @override
  final CommandHandlerFunction? afterHandler;

  @override
  final CommandHandlerFunction commandHandler;

  @override
  final String commandName;

  _InternalCommandHandler(this.commandName, this.commandHandler, {this.beforeHandler, this.afterHandler});
}