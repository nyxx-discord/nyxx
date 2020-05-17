part of nyxx.commander;

/// Handles command execution - requires to implement [commandName] field which
/// returns name of command to match message content, and [commandHandler] callback
/// which is fired when command matches message content.
abstract class CommandHandler {
  /// Executed before main [commandHandler] callback.
  /// Used to check if command can be executed in current context.
  PassHandlerFunction? get beforeHandler => null;

  /// Callback executed after [commandHandler].
  CommandHandlerFunction? get afterHandler => null;

  /// Main command callback
  CommandHandlerFunction get commandHandler;

  /// Command name
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
