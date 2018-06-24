part of discord;

/// Main handler for CommandFramework.
///   This class matches and dispatches commands to best matching contexts.
class Commands {
  List<String> _admins;
  List<Command> _commands;
  String _prefix;
  bool _helpDirect;

  /// Indicator if you want to ignore all bot messages, even if messages is current command.
  bool ignoreBots = true;

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String get prefix => _prefix;

  /// Creates commands framework handler. Requires prefix to handle commands.
  Commands(this._prefix, Client client,
      [this._admins, String gameName, this._helpDirect = true]) {
    _commands = [];

    if (gameName != null) client.user.setGame(name: gameName);

    // Listen to incoming messages and ignore all from bots (if set)
    client.onMessage.listen((MessageEvent e) async {
      if (ignoreBots && e.message.author.bot) return;

      await dispatch(e);
    });

    client.onReady.listen((ReadyEvent e) => print("[INFO] Bot started!"));
  }

  /// Dispatches onMessage event to framework.
  Future dispatch(MessageEvent e) async {
    if (!e.message.content.startsWith(prefix)) return;

    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith((prefix + 'help'))) {
      if (_helpDirect) {
        e.message.author.send(content: _createHelp(e.message.author.id));
        return;
      }

      await e.message.channel.sendMessage(content: _createHelp());
      return;
    }

    // Search for matching command in registry. If registry contains multiple commands with identical name - run first one.
    var matchedCommand = _commands
        .where((i) => e.message.content.startsWith((_prefix + i.name)))
        .first;

    if (_isUserAdmin(e.message.author.id, matchedCommand)) {
      await matchedCommand.run(e.message);
      print("[INFO] Dispatched command successfully!");
      return;
    } else {
      print("[INFO] Dispatched command successfully!");
      return;
    }

    /*
    if (matchedCommand.isAdmin) {
      if (_admins != null && _admins.any((i) => i == e.message.author.id))
        await matchedCommand.run(e.message);

      print("[INFO] Dispatched command successfully!");
      return;
    }
    */

    if (matchedCommand.requiredRoles != null) {
      var guild = e.message.guild;
      var author = e.message.author;
      var member = await guild.getMember(author);

      var hasRoles = matchedCommand.requiredRoles
          .where((i) => member.roles.contains(i))
          .toList();

      if (hasRoles == null || hasRoles.isEmpty) {
        print("[INFO] Dispatched command successfully!");
        return;
      }
    }

    await matchedCommand.run(e.message);

    print("[INFO] Dispatched command successfully!");
  }

  bool _isUserAdmin(String authorId, Command command) {
    if (command.isAdmin) if (_admins != null &&
        _admins.any((i) => i == authorId)) return true;

    return false;
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(String requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    _commands.forEach((item) {
      if (item.isAdmin && _isUserAdmin(requestedUserId, item)) {
        buffer.writeln("* ${item.name} - ${item.help} **ADMIN** ");
        buffer.writeln("\t Usage: ${item.usage}");
      } else if (!item.isAdmin) {
        buffer.writeln("* ${item.name} - ${item.help}");
        buffer.writeln("\t Usage: ${item.usage}");
      }
    });

    return buffer.toString();
  }

  /// Register new [Command] object.
  void add(Command command) {
    _commands.add(command);
    print("[INFO] Registred command: ${command.name}");
  }

  void addMany(List<Command> commands) {
    commands.forEach((c) => add(c));
  }
}
