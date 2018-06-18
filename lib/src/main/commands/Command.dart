part of discord;

/// Absctract class to factory new command
abstract class Command implements ICommand {
  /// Name of command. Text which will trigger execution
  String _name;

  /// Help message
  String _help;

  /// Example usage of command
  String _usage;

  /// Indicates if commands is restricted to admins.
  bool _isAdmin;

  /// Basic constructor to create new instance of command.
  Command(this._name, this._help, this._usage, [this._isAdmin = false]);

  /// Name of command. Text which will trigger execution
  String get name => _name;

  /// Help message
  String get help => _help;

  /// Example usage of command
  String get usage => _usage;

  /// Indicates if commands is restricted to admins.
  bool get isAdmin => _isAdmin;
}
