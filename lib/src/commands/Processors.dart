part of nyxx.commands;

/// Preprocessor allows to run code block just after finding rigt command handler and before even checking for permission.
/// It gives possibillity to check if command can be run (or not) before even starting all the process.
abstract class Preprocessor { 
  bool execute(List<Object> services, Message message);
}

/// Preprocessor allows to run code block after successfull command execuction.
/// It gives possibillity to eg. send additional data or do stuff with databases 
abstract class Postprocessor {
  void execute(List<Object> services, dynamic returns, Message message);
}