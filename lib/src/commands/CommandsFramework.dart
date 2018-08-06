part of nyxx.commands;

/// Main handler for CommandFramework.
///   This class matches and dispatches commands to best matching contexts.
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

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String prefix;

  /// Specifies list of admins which can access commands annotated as admin
  List<String> admins;

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

    onCommandNotFound = _commandNotFoundEventController.stream;
    onAdminOnlyError = _forAdminOnlyEventController.stream;
    onRequiredPermissionError = _forAdminOnlyEventController.stream;
    onCooldown = _cooldownEventController.stream;
    onCommandExecutionFail = _commandExecutionFailController.stream;
    onWrongContext = _wrongContextController.stream;
    onUnauthorizedNsfwAccess = _unauthorizedNsfwAccess.stream;
    onRequiredTopicError = _requiredTopicError.stream;

    // Listen to incoming messages and ignore all from bots (if set)
    _client.onMessage.listen((MessageEvent e) async {
      if (ignoreBots && e.message.author.bot) return;
      if (!e.message.content.startsWith(prefix)) return;

      await _dispatch(e);
    });
  }

  Future<List> matchCommand(List<String> splittedCommand) async {
    var sanitizedCommand = splittedCommand[0].replaceFirst(prefix, "");

    MethodMirror matched;
    CommandContext commandContext;
    Command _meta;
    bool found = false;

    void find(Iterable<DeclarationMirror> tmpMethods, CommandContext cmd, bool first, bool Function(Command) f) {
      for(var v in tmpMethods) {
        if (v is MethodMirror) {
          var meta = _getCmdAnnot(v, Command) as Command;

          if (f(meta)) {
            matched = v;
            _meta = meta;
            commandContext = cmd;
            if(!first)
              splittedCommand.removeRange(0, 2);
            else splittedCommand.removeAt(0);
            found = true;
            break;
          }
        }
      }
    }

    for (var cmd in _commands) {
      if(found)
        break;

      var tmpInstMirror = reflect(cmd);
      var tmpClassMirror = tmpInstMirror.type;
      var tmpMethods = tmpClassMirror.declarations;
      var tmpCommand = _getCmdAnnot(tmpClassMirror, Command) as Command;

      if(tmpCommand != null) {
        if (tmpCommand.name == sanitizedCommand || (tmpCommand.aliases != null && tmpCommand.aliases.contains(sanitizedCommand))) {
          if(splittedCommand.length > 1) {
            find(tmpMethods.values, cmd, false, (meta) => meta != null && meta.name != null && meta.name == splittedCommand[1]);
          } else {
            find(tmpMethods.values, cmd, true, (meta) => meta != null && meta.name != null && meta.name == sanitizedCommand);
          }
        }

        if(!found)
          find(tmpMethods.values, cmd, true, (meta) => meta != null && meta.main != null && meta.main);
      }
      else {
        find(tmpMethods.values, cmd, true, (meta) => meta != null && meta.name != null && meta.name  == sanitizedCommand);
      }
    }

    return [matched, commandContext, _meta, splittedCommand];
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

    var splittedCommand = e.message.content.split(' ');
    int executionCode = -1;

    var ret = await matchCommand(splittedCommand);
    MethodMirror matched = ret[0] as DeclarationMirror;
    CommandContext commandContext = ret[1] as CommandContext;
    Command _meta = ret[2] as Command;
    splittedCommand = ret[3] as List<String>;

    if (matched == null) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    Cons annot = _getCmdAnnot(matched, Cons) as Cons;
    if(annot == null)
      executionCode = -2;

    // Check for admin command and if user is admin
    if (executionCode == -1 && annot.isAdmin != null && annot.isAdmin)
      executionCode = _isUserAdmin(e.message.author.id) ? 100 : 0;

    var member = await e.message.guild.getMember(e.message.author);

    // Check if there is need to check user roles
    if (executionCode == -1 && annot.requiredRoles != null) {
      var hasRoles =
      annot.requiredRoles.where((i) => member.roles.contains(i)).toList();

      if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
    }

    // Check if user has required permissions
    if (executionCode == -1 && annot.requiredPermissions != null) {
      var total = await member.getTotalPermissions();
      for (var perm in annot.requiredPermissions) {
        if ((total.raw | perm) == 0) {
          executionCode = 1;
          break;
        }
      }
    }

    // Check for channel compatibility
    if (executionCode == -1 && annot.guildOnly != null) {
      if ((annot.guildOnly == GuildOnly.DM &&
          e.message.channel is TextChannel) ||
          (annot.guildOnly == GuildOnly.GUILD &&
              (e.message.channel is DMChannel ||
                  e.message.channel is GroupDMChannel))) {
        executionCode = 3;
      }
    }

    // Check for channel nsfw
    if (executionCode == -1 && annot.isNsfw != null && annot.isNsfw) {
      if (e.message.channel is TextChannel) {
        var ch = e.message.channel as TextChannel;
        if(ch.nsfw == null) executionCode = 4;
          else if (!ch.nsfw) executionCode = 4;
      } else if (!(e.message.channel is DMChannel) ||
          !(e.message.channel is GroupDMChannel)) executionCode = 4;
    }

    // Check for channel topics
    if (executionCode == -1 && annot.topics != null &&
        e.message.channel is TextChannel) {
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

    //Check if user is on cooldown
    if (executionCode == -1 &&
        annot.cooldown != null &&
        annot.cooldown >
            0) if (!(await _cooldownCache.canExecute(
        e.message.author.id, _meta.name, annot.cooldown * 1000)))
      executionCode = 2;

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
        var params = await _collectParams(matched, splittedCommand, e.message);

        commandContext.guild = e.message.guild;
        commandContext.message = e.message;
        commandContext.author = e.message.author;
        commandContext.channel = e.message.channel;

        new Future(() {
          try {
            var newInstance = reflect(commandContext);
            newInstance.invoke(matched.simpleName, params);
          } catch (err) {
            _commandExecutionFailController
                .add(new CommandExecutionFailEvent._new(e.message, err));
          }
        });

        logger.fine("Command executed");
        break;
    }
  }

  String sTrim(String str) {
    return str.substring(6).replaceAll("\"", "").replaceAll("(", "").replaceAll(")", "");
  }

  /// Register new [CommandContext] object.
  void add(CommandContext command) {
    var cmd = sTrim(reflect(command).type.simpleName.toString());

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
        print(e);
        throw new Exception(
            "Service [${sTrim(cm.simpleName.toString())}] constructor not satisfied!");
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
        print(e);
        throw new Exception(
            "Command [${sTrim(cm.simpleName.toString())}] constructor not satisfied!");
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
          try {
            collected.add(splitted[index]);
          } catch (e) {}
          break;
        case int:
          try {
            var d = int.parse(splitted[index]);
            collected.add(d);
          } catch (e) {}
          break;
        case double:
          try {
            var d = double.parse(splitted[index]);
            collected.add(d);
          } catch (e) {}
          break;
        case DateTime:
          try {
            var d = DateTime.parse(splitted[index]);
            collected.add(d);
          } catch (e) {}
          break;
        case TextChannel:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.channels[new Snowflake(id)]);
          } catch (e) {}
          break;
        case User:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.client.users[new Snowflake(id)]);
          } catch (e) {}
          break;
        case Role:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.roles[new Snowflake(id)]);
          } catch (e) {}
          break;
        case GuildEmoji:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.emojis[new Snowflake(id)]);
          } catch (e) {}
          break;
        case UnicodeEmoji:
          try {
            var code = splitted[index].codeUnits[0].toRadixString(16);
            //print(code);
            collected.add(await EmojisUnicode.fromHexCode(code));
          } catch (e) {}
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

        collected.add(splitted.getRange(index, splitted.length).toList());
        break;
      }

      if (!(await parsePrimitives(type))) {
        _services.forEach((s) {
          if (s.runtimeType == type) {
            collected.add(s);
          }
        });
      }
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
