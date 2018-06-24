part of discord;

/// Absctract class to factory new command
abstract class Command {
  /// Name of command. Text which will trigger execution
  String name;

  /// Help message
  String help;

  /// Example usage of command
  String usage;

  /// Indicates if commands is restricted to admins
  bool isAdmin;

  /// List of roles required to execute command
  List<String> requiredRoles;

  /// Basic constructor to create new instance of command.
  Command(this.name, this.help, this.usage,
      [this.isAdmin = false, this.requiredRoles = null]);

  /// Function which will be invoked when command triggers
  Future run(Message message);
}
