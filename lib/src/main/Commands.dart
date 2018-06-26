part of discord;

/// Main handler for CommandFramework.
///   This class matches and dispatches commands to best matching contexts.
class Commands {
  List<String> _admins;
  List<Command> _commands;

  StreamController<Message> _cooldownEventController;
  StreamController<Message> _commandNotFoundEventController;
  StreamController<Message> _requiredPermissionEventController;
  StreamController<Message> _forAdminOnlyEventController;

  CooldownCache _cooldownCache;

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String prefix;

  /// Indicates if bots help message is sent to user via PM. True by default.xc
  bool helpDirect = true;

  /// Indicator if you want to ignore all bot messages, even if messages is current command.
  bool ignoreBots = true;

  /// Fires when invoked command dont exists in registry
  Stream<Message> commandNotFoundEvent;

  /// Invoked when non-admin user uses admin-only command.
  Stream<Message> forAdminOnlyEvent;

  /// Invoked when user didn't have enough permissions.
  Stream<Message> requiredPermissionEvent;

  /// Invoked when user hits command rate limit.
  Stream<Message> cooldownEvent;

  /// Creates commands framework handler. Requires prefix to handle commands.
  Commands(this.prefix, Client client, [this._admins, String gameName]) {
    _commands = [];
    _cooldownCache = new CooldownCache();

    _commandNotFoundEventController = new StreamController<Message>();
    _requiredPermissionEventController = new StreamController<Message>();
    _forAdminOnlyEventController = new StreamController<Message>();
    _cooldownEventController = new StreamController<Message>();

    commandNotFoundEvent = _commandNotFoundEventController.stream;
    forAdminOnlyEvent = _forAdminOnlyEventController.stream;
    requiredPermissionEvent = _forAdminOnlyEventController.stream;
    cooldownEvent = _cooldownEventController.stream;

    if (gameName != null) client.user.setGame(name: gameName);

    // Listen to incoming messages and ignore all from bots (if set)
    client.onMessage.listen((MessageEvent e) async {
      if (ignoreBots && e.message.author.bot) return;

      await _dispatch(e);
    });

    client.onReady.listen((ReadyEvent e) => print("[INFO] Bot started!"));
  }

  /// Dispatches onMessage event to framework.
  Future _dispatch(MessageEvent e) async {
    if (!e.message.content.startsWith(prefix)) return;

    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith((prefix + 'help'))) {
      if (helpDirect) {
        e.message.author.send(content: _createHelp(e.message.author.id));
        return;
      }

      await e.message.channel
          .sendMessage(content: _createHelp(e.message.author.id));
      return;
    }

    // Search for matching command in registry. If registry contains multiple commands with identical name - run first one.
    var commandCollection =
        _commands.where((i) => e.message.content.startsWith((prefix + i.name)));

    // If there is no command - return
    if (commandCollection.isEmpty) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    // Get command and set execution code to default value;
    var matchedCommand = commandCollection.first;
    var executionCode = -1;

    // Check for admin command and if user is admin
    if (matchedCommand.isAdmin)
      executionCode = _isUserAdmin(e.message.author.id) ? 100 : 0;

    // Check if there is need to check user roles
    if (matchedCommand.requiredRoles != null && executionCode == -1) {
      var member = await e.message.guild.getMember(e.message.author);

      var hasRoles = matchedCommand.requiredRoles
          .where((i) => member.roles.contains(i))
          .toList();

      if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
    }

    //Check if user is on cooldown
    if (executionCode == -1 &&
        matchedCommand.cooldown >
            0) if (!(await _cooldownCache.canExecute(
        e.message.author.id,
        matchedCommand.name,
        matchedCommand.cooldown * 1000))) executionCode = 2;

    // Switch between execution codes
    switch (executionCode) {
      case 0:
        _forAdminOnlyEventController.add(e.message);
        break;
      case 1:
        _requiredPermissionEventController.add(e.message);
        break;
      case 2:
        _cooldownEventController.add(e.message);
        break;
      case -1:
      case 100:
        await matchedCommand.run(e.message);
        print("[INFO] Dispatched command successfully!");
        break;
    }
  }

  bool _isUserAdmin(String authorId) {
    return (_admins != null && _admins.any((i) => i == authorId));
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(String requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    _commands.forEach((item) {
      if(!item.isHidden)
        if (item.isAdmin && _isUserAdmin(requestedUserId)) {
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

  /// Register many [Command] instances.
  void addMany(List<Command> commands) {
    commands.forEach((c) => add(c));
  }
}
