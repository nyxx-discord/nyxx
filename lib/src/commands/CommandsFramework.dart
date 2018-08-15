part of nyxx.commands;

/// Main point of commands in nyx.
/// It gets all sent messages and matches to registered command and invokes
/// its action.
class CommandsFramework {
  List<CommandContext> _commands;
  List<TypeConverter> _typeConverters;
  CooldownCache _cooldownCache;
  List<Object> _services = new List();
  Client _client;

  StreamController<Message> _cooldownEventController;
  StreamController<Message> _commandNotFoundEventController;
  StreamController<Message> _requiredPermissionEventController;
  StreamController<Message> _forAdminOnlyEventController;
  StreamController<CommandExecutionFailEvent> _commandExecutionFailController;
  StreamController<Message> _wrongContextController;
  StreamController<Message> _unauthorizedNsfwAccess;
  StreamController<Message> _requiredTopicError;
  //StreamController<CommandParsingFail> _commandParsingFail;

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String prefix;

  /// Specifies list of admins which can access commands annotated as admin
  List<Snowflake> admins;

  /// Indicates if bots help message is sent to user via PM. True by default.
  bool helpDirect = true;

  /// Indicator if you want to ignore all bot messages, even if messages is current command. True by default.
  bool ignoreBots = true;

  /// Sets default bots game
  set game(Game game) => _client.user.setGame(game: game);

  /// Fires when invoked command dont exists in registry
  Stream<Message> onCommandNotFound;

  /// Invoked when non-admin user uses admin-only command.
  Stream<Message> onAdminOnlyError;

  /// Invoked when user didn't have enough permissions.
  Stream<Message> onRequiredPermissionError;

  /// Invoked when user hits command ratelimit.
  Stream<Message> onCooldown;

  /// Emitted when command execution fails
  Stream<CommandExecutionFailEvent> onCommandExecutionFail;

  /// Emitted when command is only for DM and is invoked on Guild etc
  Stream<Message> onWrongContext;

  /// Emitted  when nsfw command is invoked in non nsfw context;
  Stream<Message> onUnauthorizedNsfwAccess;

  /// Emitted when command is invoked in channel without required topic
  Stream<Message> onRequiredTopicError;

  /// Emitted when command fails to parse. Eg. Wrong arguments
  //Stream<CommandParsingFail> onCommandParsingFail;

  /// Logger instance
  final Logger logger = new Logger.detached("CommandsFramework");

  /// Creates commands framework handler. Requires prefix to handle commands.
  CommandsFramework(this.prefix, this._client) {
    this._commands = new List();
    _cooldownCache = new CooldownCache();

    _commandNotFoundEventController = new StreamController.broadcast();
    _requiredPermissionEventController = new StreamController.broadcast();
    _forAdminOnlyEventController = new StreamController.broadcast();
    _cooldownEventController = new StreamController.broadcast();
    _commandExecutionFailController = new StreamController.broadcast();
    _wrongContextController = new StreamController.broadcast();
    _unauthorizedNsfwAccess = new StreamController.broadcast();
    _requiredTopicError = new StreamController.broadcast();
    //_commandParsingFail = new StreamController.broadcast();

    onCommandNotFound = _commandNotFoundEventController.stream;
    onAdminOnlyError = _forAdminOnlyEventController.stream;
    onRequiredPermissionError = _forAdminOnlyEventController.stream;
    onCooldown = _cooldownEventController.stream;
    onCommandExecutionFail = _commandExecutionFailController.stream;
    onWrongContext = _wrongContextController.stream;
    onUnauthorizedNsfwAccess = _unauthorizedNsfwAccess.stream;
    onRequiredTopicError = _requiredTopicError.stream;
    //onCommandParsingFail = _commandParsingFail.stream;

    // Listen to incoming messages and ignore all from bots (if set)
    _client.onMessage.listen((MessageEvent e) async {
      if (ignoreBots && e.message.author.bot) return;
      if (!e.message.content.startsWith(prefix)) return;

      await _dispatch(e);
    });
  }

  List<Object> find(Iterable<DeclarationMirror> tmpMethods, CommandContext cmd,
      bool first, List<String> splStr, bool Function(Command) f) {
    for (var v in tmpMethods) {
      if (v is MethodMirror) {
        var meta = _getCmdAnnot(v, Command) as Command;

        if (f(meta)) {
          if (!first)
            splStr.removeRange(0, 2);
          else
            splStr.removeAt(0);

          return [v, meta];
        }
      }
    }

    return null;
  }

  Future<List> _matchCommand(List<String> splittedCommand) async {
    List<Object> matched;

    InstanceMirror tmpInstMirror;
    ClassMirror tmpClassMirror;
    Map<Symbol, DeclarationMirror> tmpMethods;

    for (var cmd in _commands) {
      tmpInstMirror = reflect(cmd);
      tmpClassMirror = tmpInstMirror.type;
      tmpMethods = tmpClassMirror.declarations;
      var tmpCommand = _getCmdAnnot(tmpClassMirror, Command) as Command;

      if (tmpCommand != null) {
        if (tmpCommand.name == splittedCommand[0] ||
            (tmpCommand.aliases != null &&
                tmpCommand.aliases.contains(splittedCommand[0]))) {
          if (splittedCommand.length > 1) {
            matched = find(
                tmpMethods.values,
                cmd,
                false,
                splittedCommand,
                (meta) =>
                    meta != null &&
                    meta.name != null &&
                    meta.name == splittedCommand[1]);

            if (matched != null) break;
          } else {
            matched = find(tmpMethods.values, cmd, true, splittedCommand,
                (meta) => meta != null && meta.main != null && meta.main);

            if (matched != null) break;
          }
        }
      } else {
        matched = find(
            tmpMethods.values,
            cmd,
            true,
            splittedCommand,
            (meta) =>
                meta != null &&
                meta.name != null &&
                meta.name == splittedCommand[0]);

        if (matched != null) break;
      }
    }

    if (matched == null) return null;

    return [matched[0], matched[1], splittedCommand, tmpInstMirror];
  }

  /// Dispatches onMessage event to framework.
  Future _dispatch(MessageEvent e) async {
    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith((prefix + 'help'))) {
      if (helpDirect) {
        e.message.author.send(content: _createHelp(e.message.author.id));
        return;
      }

      await e.message.channel.send(content: _createHelp(e.message.author.id));
      return;
    }

    var splittedCommand =
        e.message.content.replaceFirst(prefix, "").trim().split(' ');
    int executionCode = -1;
    var ret = await _matchCommand(splittedCommand);

    if (ret == null) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    MethodMirror matched = ret[0] as MethodMirror;
    Command _meta = ret[1] as Command;
    splittedCommand = ret[2] as List<String>;
    InstanceMirror instMirror = ret[3] as InstanceMirror;

    Cons annot = _getCmdAnnot(matched, Cons) as Cons;
    if (annot == null) executionCode = -2;

    // Check for admin command and if user is admin
    if (executionCode == -1 && annot.isAdmin != null && annot.isAdmin)
      executionCode = _isUserAdmin(e.message.author.id) ? 100 : 0;
    if (executionCode == -1) {
      //Check if user is on cooldown
      if (annot.cooldown != null &&
          annot.cooldown >
              0) if (!(await _cooldownCache.canExecute(
          e.message.author.id, _meta.name, annot.cooldown * 1000)))
        executionCode = 2;

      var member = await e.message.guild.getMember(e.message.author);

      // Check if there is need to check user roles
      if (annot.requiredRoles != null) {
        var hasRoles = member.roles
            .map((f) => f.id)
            .where((t) => annot.requiredRoles.contains(t));

        if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
      }

      // Check if user has required permissions
      if (annot.requiredPermissions != null) {
        var total = await member.getTotalPermissions();
        for (var perm in annot.requiredPermissions) {
          if ((total.raw | perm) == 0) {
            executionCode = 1;
            break;
          }
        }
      }

      // Check for channel compatibility
      if (annot.guildOnly != null) {
        if ((annot.guildOnly == GuildOnly.DM &&
                e.message.channel is TextChannel) ||
            (annot.guildOnly == GuildOnly.GUILD &&
                (e.message.channel is DMChannel ||
                    e.message.channel is GroupDMChannel))) {
          executionCode = 3;
        }
      }

      // Check for channel nsfw
      if (annot.isNsfw != null && annot.isNsfw) {
        if (e.message.channel is TextChannel) {
          var ch = e.message.channel as TextChannel;
          if (ch.nsfw == null)
            executionCode = 4;
          else if (!ch.nsfw) executionCode = 4;
        } else if (!(e.message.channel is DMChannel) ||
            !(e.message.channel is GroupDMChannel)) executionCode = 4;
      }

      // Check for channel topics
      if (annot.topics != null && e.message.channel is TextChannel) {
        var topic = (e.message.channel as TextChannel).topic;
        var list = topic
            .substring(topic.indexOf("[") + 1, topic.indexOf("]"))
            .split(",");

        var total = false;
        for (var topic in annot.topics) {
          if (list.contains(topic)) {
            total = true;
            break;
          }
        }

        if (!total) executionCode = 5;
      }
    }

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
      case 3:
        _wrongContextController.add(e.message);
        break;
      case 4:
        _unauthorizedNsfwAccess.add(e.message);
        break;
      case 5:
        _requiredTopicError.add(e.message);
        break;
      case -1:
      case -2:
      case 100:
        new Future(() async {
          try {
            var params =
                await _collectParams(matched, splittedCommand, e.message);

            instMirror.setField(new Symbol("guild"), e.message.guild);
            instMirror.setField(new Symbol("message"), e.message);
            instMirror.setField(new Symbol("author"), e.message.author);
            instMirror.setField(new Symbol("channel"), e.message.channel);
            instMirror.invoke(matched.simpleName, params);
          } catch (err, stacktrace) {
            _commandExecutionFailController
                .add(new CommandExecutionFailEvent._new(e.message, err));
            logger.severe("ERROR OCCURED WHEN INVOKING COMMAND \n $stacktrace");
          }
        });

        logger.fine("Command -${_meta.name}- executed");
        break;
    }
  }

  /// Register new [CommandContext] object.
  void add(CommandContext command) {
    var cmd = util.getSymbolName(reflect(command).type.simpleName);

    command.logger = new Logger.detached("Command[$cmd]");

    _commands.add(command);
    logger.info("Command[$cmd] added to registry");
  }

  /// Register many [CommandContext] instances.
  void addMany(List<CommandContext> commands) =>
      commands.forEach((c) => add(c));

  /// Allows to register new converters for custom type
  void registerTypeConverters(List<TypeConverter> converters) =>
      _typeConverters = converters;

  /// Register services to injected into commands modules. Has to be executed before registering commands.
  /// There cannot be more than 1 dependency with single type. Only first will be injected.
  void registerServices(List<Object> services) =>
      this._services.addAll(services);

  void _registerLibrary(Type type, Function(List<dynamic>, ClassMirror) func) {
    var superClass = reflectClass(type);
    var mirrorSystem = currentMirrorSystem();

    mirrorSystem.libraries.forEach((uri, lib) {
      lib.declarations.forEach((s, cm) {
        if (cm is ClassMirror) {
          if (cm.isSubclassOf(superClass) && !cm.isAbstract) {
            var ctor = cm.declarations.values.toList().firstWhere((m) {
              if (m is MethodMirror) return m.isConstructor;

              return false;
            }) as MethodMirror;

            var params = ctor.parameters;
            var toInject = new List<dynamic>();

            for (var param in params) {
              var type = param.type.reflectedType;

              for (var service in _services) {
                if (service.runtimeType == type) toInject.add(service);
              }
            }

            func(toInject, cm);
          }
        }
      });
    });
  }

  /// Register all services in current isolate. It captures all classes which inherits from [Service] class and performs dependency injection if possible.
  void registerLibraryServices() {
    _registerLibrary(Service, (toInject, cm) {
      try {
        var serv = cm.newInstance(new Symbol(''), toInject).reflectee;
        _services.add(serv);
      } catch (e) {
        throw new Exception(
            "Service [${util.getSymbolName(cm.simpleName)}] constructor not satisfied!");
      }
    });
  }

  /// Register commands in current Isolate's libraries. Basically loads all classes as commnads with [CommandContext] superclass.
  /// Performs dependency injection when instantiate commands. And throws [Exception] when there are missing services
  void registerLibraryCommands() {
    _registerLibrary(CommandContext, (toInject, cm) {
      try {
        var cmd = cm.newInstance(new Symbol(''), toInject).reflectee
            as CommandContext;
        add(cmd);
      } catch (e) {
        throw new Exception(
            "Command [${util.getSymbolName(cm.simpleName)}] constructor not satisfied!");
      }
    });
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(Snowflake requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    for (var cmd in _commands)
      cmd.getHelp(_isUserAdmin(requestedUserId), buffer);

    return buffer.toString();
  }

  // Groups params into
  List<String> _groupParams(List<String> splitted) {
    var tmpList = new List<String>();
    var isInto = false;

    var finalList = new List<String>();

    for (var item in splitted) {
      if (isInto) {
        tmpList.add(item);
        if (item.contains("\"")) {
          isInto = false;
          finalList.add(tmpList.join(" ").replaceAll("\"", ""));
          tmpList.clear();
        }
        continue;
      }

      if (item.contains("\"") && !isInto) {
        isInto = true;
        tmpList.add(item);
        continue;
      }

      finalList.add(item);
    }

    return finalList;
  }

  RegExp _entityRegex = new RegExp(r"<(@|@!|@&|#|a?:(.+):)([0-9]+)>");

  Future<List<Object>> _collectParams(
      MethodMirror method, List<String> splitted, Message e) async {
    var params = method.parameters;
    splitted = _groupParams(splitted);

    List<Object> collected = new List();
    var index = -1;

    Future<bool> parsePrimitives(Type type) async {
      index++;
      switch (type) {
        case String:
          collected.add(splitted[index]);
          break;
        case int:
          var d = int.parse(splitted[index]);
          collected.add(d);
          break;
        case double:
          var d = double.parse(splitted[index]);
          collected.add(d);
          break;
        case DateTime:
          var d = DateTime.parse(splitted[index]);
          collected.add(d);
          break;
        case TextChannel:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.channels[new Snowflake(id)]);
          break;
        case User:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.client.users[new Snowflake(id)]);
          break;
        case Role:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.roles[new Snowflake(id)]);
          break;
        case GuildEmoji:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.emojis[new Snowflake(id)]);
          break;
        case UnicodeEmoji:
          var code = splitted[index].codeUnits[0].toRadixString(16);
          collected.add(await util.EmojisUnicode.fromHexCode(code));
          break;
        default:
          if (_typeConverters == null) return false;

          for (var converter in _typeConverters) {
            if (type == converter.getType()) {
              var t = converter.parse(splitted[index], e);
              if (t != null) {
                collected.add(t);
                return true;
              }
            }
          }
          return false;
      }

      return true;
    }

    for (var e in params) {
      var type = e.type.reflectedType;

      if (_getCmdAnnot(e, Remainder) != null) {
        index++;
        var range = splitted.getRange(index, splitted.length).toList();

        if (type == String) {
          collected.add(range.join(" "));
          break;
        }

        collected.add(range);
        break;
      }

      bool pp;
      try {
        pp = await parsePrimitives(type);
      } catch (e) {
        pp = false;
      }

      if (pp) continue;

      try {
        collected.add(_services.firstWhere((s) => s.runtimeType == type));
      } catch (e) {}
    }

    return collected;
  }

  Object _getCmdAnnot(DeclarationMirror declaration, Type type) {
    for (var instance in declaration.metadata) {
      if (instance.hasReflectee) {
        var reflectee = instance.reflectee;
        if (reflectee.runtimeType == type) {
          return reflectee;
        }
      }
    }
    return null;
  }

  bool _isUserAdmin(Snowflake authorId) {
    return (admins != null && admins.any((i) => i == authorId));
  }
}
