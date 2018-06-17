part of discord;

class Commands {
  String _prefix;
  String get prefix => _prefix;

  List<Command> _commands;

  /// Creates commands framework handler. Requires prefix to handle commands.
  Commands(this._prefix, Client client) {
    _commands = [];

    client.onMessage.listen((MessageEvent e) {
      if (!e.message.author.bot)
        dispatch(e);
    });

    client.onReady.listen((ReadyEvent e) => print("[INFO] Bot started!"));
  }

  /// Dispatches onMessage event to framework.
  void dispatch(MessageEvent e) {
    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith('!help'))
      e.message.channel.sendMessage(content: _createHelp());
    // Search for matching command in registry. If registry contains multiple commands with identical name - run first one.
    else if (e.message.content.startsWith(prefix)) {
      var matched_commands = _commands
        .where((i) => e.message.content.startsWith((_prefix + i.name))).first;
      matched_commands.run(e.message);
    }
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
  void add(ICommand command) {
    _commands.add(command);
    print("[INFO] Registred command: ${command.name}");
  }

  void addMany(List<ICommand> commands) {
    commands.forEach((c) => add(c));
  }
}
