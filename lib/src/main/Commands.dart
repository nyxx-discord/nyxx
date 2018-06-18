part of discord;

/// Handler for commands framwork.
/// This class matches and dispatches commands to best matchig contexts.
class Commands {
  List<String> _admins;
  List<Command> _commands;

  String _prefix;

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String get prefix => _prefix;

  /// Creates commands framework handler. Requires prefix to handle commands.
  Commands(this._prefix, Client client, [this._admins]) {
    _commands = [];

    // Listen to incoming messages and ignore all from bots
    client.onMessage.listen((MessageEvent e) async {
      if (!e.message.author.bot) await dispatch(e);
    });

    client.onReady.listen((ReadyEvent e) => print("[INFO] Bot started!"));
  }

  /// Dispatches onMessage event to framework.
  Future dispatch(MessageEvent e) async {
    if (!e.message.content.startsWith(prefix)) return;

    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith('!help'))
      e.message.channel.sendMessage(content: _createHelp());

    // Search for matching command in registry. If registry contains multiple commands with identical name - run first one.
    var matchedCommand = _commands
        .where((i) => e.message.content.startsWith((_prefix + i.name)))
        .first;

    if (matchedCommand.isAdmin)
      if(_admins != null && _admins.any((i) => i == e.message.author.id)) { }
    else
      return;

    await matchedCommand.run(e.message);

    print("[INFO] Dispatched command successfully!");
  }

  /// Creates help String based on registred commands metadata.
  String _createHelp() {
    var buffer = new StringBuffer();

    buffer.writeln("\n**Available commands:**");

    _commands.forEach((item) {
      buffer.writeln("* ${item.name} - ${item.help}");
      buffer.writeln("\t Usage: ${item.usage}");
    });

    return buffer.toString();
  }

  /// Register new [Command] object.
  void add(Command command) {
    _commands.add(command);
    print("[INFO] Registred command: ${command.name}");
  }

  /// Register many commands by passing list
  void addMany(List<ICommand> commands) {
    commands.forEach((c) => add(c));
  }
}
