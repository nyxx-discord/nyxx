part of discord;

/// Absctract class to factory new command
abstract class Command implements ICommand {
  /// Name of command. Text which will trigger execution
  String _name;

  /// Help message
  String _help;

  /// Example usage of command
  String _usage;

  /// Name of command. Text which will trigger execution
  String get name => _name;

  /// Help message
  String get help => _help;

  /// Example usage of command
  String get usage => _usage;

  Command(this._name, this._help, this._usage);
}
