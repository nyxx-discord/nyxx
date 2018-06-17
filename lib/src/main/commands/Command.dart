part of discord;

abstract class Command implements ICommand {
  String _name;
  String _help;
  String _usage;

  String get name => _name;
  String get help => _help;
  String get usage => _usage;

  Command(this._name, this._help, this._usage);
}
