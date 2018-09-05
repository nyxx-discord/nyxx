part of nyxx.commands;

/// Emitted when command execution fails
class CommandExecutionFailEvent {
  /// Message which caused error
  Message message;

  /// Error object
  dynamic exception;

  CommandExecutionFailEvent._new(this.message, this.exception);
}

/// Emitted when dispatch function fails when checking preprocessors
class PreprocessorErrorEvent {
  /// Message on which preprocessor fails
  Message message;
  /// Failed preprocessor;
  Preprocessor preprocessor;

  PreprocessorErrorEvent._new(this.message, this.preprocessor);
}

/// Emitted when parsing error occurs
class CommandParsingFail {
  /// Error of exception
  Exception exception;

  /// Command string on which error occurs
  String commandStr;

  CommandParsingFail(this.exception, this.commandStr);
}
