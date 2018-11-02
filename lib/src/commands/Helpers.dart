part of nyxx.commands;

enum ExecutionErrorType {
  commandNotFound,
  botPermissionError,
  userPermissionsError,
  wrongContext,
  nfswAccess,
  requiredTopic,
  adminOnly,
  cooldown,
  roleRequired,
  preprocessorFail,
  preprocessorException,
  commandFailed,
  requiresVoice
}

/// Exception which can occur when [CommandsFramework] isn't able to finish execution of command
class CommandExecutionError implements Exception {
  /// Type of error
  ExecutionErrorType type;

  /// Message on which error occurred
  Message message;

  /// Exception associated with failure. Can be null.
  Exception exception;

  /// Additional info. Eg. Preprocessor error message
  String additionalInfo;

  CommandExecutionError(this.type, this.message,
      [this.exception, this.additionalInfo]);

  @override
  String toString() =>
      "[$type] [$message] ${additionalInfo ?? ""} ${exception ?? ""}";
}

/// Result of [Preprocessor] execution. Can be either success or error.
/// Error constructor allows to return message and optionally [Exception] associated with error
class PreprocessorResult {
  /// Optional info
  Exception exception;

  /// Error message
  String message;

  /// Whether preprocessor is successful
  final bool isSuccessful;

  PreprocessorResult.success() : isSuccessful = true;
  PreprocessorResult.error(this.message, [this.exception])
      : isSuccessful = false;
}
