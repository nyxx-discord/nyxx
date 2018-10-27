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

class CommandExecutionError {
  ExecutionErrorType type;

  Message message;

  Exception exception;
  String additionalInfo;

  CommandExecutionError(this.type, this.message, [this.exception, this.additionalInfo]);
}

class PreprocessorResult {
  Exception exception;
  String message;

  bool isSuccessful = false;

  PreprocessorResult.success() : isSuccessful = true;
  PreprocessorResult.error(this.message, [this.exception]);
}