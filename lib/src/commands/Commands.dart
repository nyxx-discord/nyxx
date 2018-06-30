part of nyxx.commands;

/// Main handler for CommandFramework.
///   This class matches and dispatches commands to best matching contexts.
abstract class Commands {
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

      await dispatch(e);
    });

    client.onReady.listen((ReadyEvent e) => print("[INFO] Bot started!"));
  }

  /// Dispatched message to registered commands 
  Future dispatch(MessageEvent e);
  
  bool _isUserAdmin(String authorId) {
    return (_admins != null && _admins.any((i) => i == authorId));
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(String requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    _commands.forEach((item) {
      if (!item.isHidden) if (item.isAdmin && _isUserAdmin(requestedUserId)) {
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
