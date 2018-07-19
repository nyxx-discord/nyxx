part of nyxx.commands;

/// Emitted when command execution fails
class CommandExecutionFailEvent {
  /// Message which caused error
  Message message;

  /// Error object
  dynamic exception;

  CommandExecutionFailEvent._new(this.message, this.exception);
}
