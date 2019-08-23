part of nyxx.commands;

/// Preprocessor allows to run code block just after finding right command handler and before even checking for permission.
/// It gives possibility to check if command can be run (or not) before even starting all the process.
abstract class Preprocessor {
  Future<PreprocessorResult> execute(List<Object> services, Message message);
}

/// Postprocessor allows to run code block after successful command execution.
/// It gives possibility to eg. send additional data or do stuff with databases
abstract class Postprocessor {
  Future<void> execute(List<Object> services, dynamic returns, Message message);
}
