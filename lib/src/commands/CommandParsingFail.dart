part of nyxx.commands;

/// Emitted when parsing error occurs
class CommandParsingFail {
  /// Error of exception
  Exception exception;

  /// Command string on which error occurs
  String commandStr;

  CommandParsingFail(this.exception, this.commandStr);
}
