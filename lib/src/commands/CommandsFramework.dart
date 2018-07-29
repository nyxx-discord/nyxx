part of nyxx.commands;

/// Main handler for CommandFramework.
///   This class matches and dispatches commands to best matching contexts.
class CommandsFramework {
  List<String> _admins;
  List<CommandContext> _commands;
  List<TypeConverter> _typeConverters;

  List<Object> _services = new List();

  StreamController<Message> _cooldownEventController;
  StreamController<Message> _commandNotFoundEventController;
  StreamController<Message> _requiredPermissionEventController;
  StreamController<Message> _forAdminOnlyEventController;
  StreamController<CommandExecutionFailEvent> _commandExecutionFailController;
  StreamController<Message> _onWrongContextController;

  CooldownCache _cooldownCache;

  /// Prefix needed to dispatch a commands.
  /// All messages without this prefix will be ignored
  String prefix;

  /// Indicates if bots help message is sent to user via PM. True by default.xc
  bool helpDirect = true;

  /// Indicator if you want to ignore all bot messages, even if messages is current command.
  bool ignoreBots = true;

  /// Fires when invoked command dont exists in registry
  Stream<Message> onCommandNotFound;

  /// Invoked when non-admin user uses admin-only command.
  Stream<Message> onAdminOnlyError;

  /// Invoked when user didn't have enough permissions.
  Stream<Message> onRequiredPermissionError;

  /// Invoked when user hits command ratelimit.
  Stream<Message> onCooldown;

  /// Emmited when command execution fails
  Stream<CommandExecutionFailEvent> onCommandExecutionFail;

  /// Emitted when command is only for DM and is invoked on Guild etc
  Stream<Message> onWrongContext;

  /// Logger instance
  final Logger logger = new Logger.detached("CommandsFramework");

  /// Creates commands framework handler. Requires prefix to handle commands.
  CommandsFramework(this.prefix, Client client,
      [this._admins, String gameName]) {
    _commands = [];
    _cooldownCache = new CooldownCache();

    _commandNotFoundEventController = new StreamController.broadcast();
    _requiredPermissionEventController = new StreamController.broadcast();
    _forAdminOnlyEventController = new StreamController.broadcast();
    _cooldownEventController = new StreamController.broadcast();
    _commandExecutionFailController = new StreamController.broadcast();
    _onWrongContextController = new StreamController.broadcast();

    onCommandNotFound = _commandNotFoundEventController.stream;
    onAdminOnlyError = _forAdminOnlyEventController.stream;
    onRequiredPermissionError = _forAdminOnlyEventController.stream;
    onCooldown = _cooldownEventController.stream;
    onCommandExecutionFail = _commandExecutionFailController.stream;
    onWrongContext = _onWrongContextController.stream;

    if (gameName != null) client.user.setGame(name: gameName);

    // Listen to incoming messages and ignore all from bots (if set)
    client.onMessage.listen((MessageEvent e) async {
      if (ignoreBots && e.message.author.bot) return;

      await _dispatch(e);
    });
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

      await e.message.channel.send(content: _createHelp(e.message.author.id));
      return;
    }

    ClassMirror classMirror;
    Command command;
    var commandContext;

    var splittedCommand = e.message.content.split(' ');
    var splCommand = splittedCommand[0].replaceFirst(prefix, "");

    for (var cmd in _commands) {
      var tmpInstMirror = reflect(cmd);
      var tmpClassMirror = tmpInstMirror.type;
      var tmpCommand = _getCmdAnnot(tmpClassMirror, Command) as Command;

      if (tmpCommand.name == splCommand ||
          (tmpCommand.aliases != null &&
              tmpCommand.aliases.contains(splCommand))) {
        classMirror = tmpClassMirror;
        command = tmpCommand;
        commandContext = cmd;

        break;
      }
    }

    // If there is no command - return
    if (classMirror == null || command == null) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    var executionCode = -1;

    var matched;
    var subcommand;
    var methods = classMirror.declarations;

    if (splittedCommand.length > 1) {
      subcommand = splittedCommand[1];
      methods.forEach((k, v) {
        if (v is MethodMirror) {
          var meta = _getCmdAnnot(v, Subcommand) as Subcommand;

          if (meta != null && meta.cmd == subcommand) {
            matched = v;
            splittedCommand.removeRange(0, 2);
            return;
          }
        }
      });
    }

    if (matched == null) {
      methods.forEach((k, v) {
        if (v is MethodMirror) {
          var meta = _getCmdAnnot(v, Maincommand);

          if (meta != null) {
            matched = v;
            splittedCommand.removeAt(0);
            return;
          }
        }
      });
    }

    if (matched == null) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    var annot = _getCmdAnnot(matched, Maincommand) as AnnotCommand;
    if (annot == null)
      annot = _getCmdAnnot(matched, Subcommand) as AnnotCommand;

    // Check for admin command and if user is admin
    if (annot.isAdmin != null && annot.isAdmin)
      executionCode = _isUserAdmin(e.message.author.id) ? 100 : 0;

    var member = await e.message.guild.getMember(e.message.author);

    // Check if there is need to check user roles
    if (annot.requiredRoles != null && executionCode == -1) {
      var hasRoles =
          annot.requiredRoles.where((i) => member.roles.contains(i)).toList();

      if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
    }

    // Check if user has required permissions
    if(annot.requiredPermissions != null && executionCode == -1) {
      var total = await member.getTotalPermissions();
      for(var perm in annot.requiredPermissions) {
        if((total.raw | perm) == 0) {
          executionCode = 1;
          break;
        }
      }
    }

    // Check for channel compatibility
    if(annot.guildOnly != null && executionCode == -1) {
      if((annot.guildOnly == GuildOnly.DM && e.message.channel is TextChannel)
          || (annot.guildOnly == GuildOnly.GUILD && (e.message.channel is DMChannel
              || e.message.channel is GroupDMChannel))) {
        executionCode = 3;
      }
    }

    //Check if user is on cooldown
    if (executionCode == -1 &&
        annot.cooldown != null &&
        annot.cooldown >
            0) if (!(await _cooldownCache.canExecute(
        e.message.author.id, command.name, annot.cooldown * 1000)))
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
        _onWrongContextController.add(e.message);
        break;
      case -1:
      case 100:
        var params = _collectParams(matched, splittedCommand, e.message);

        try {
          commandContext.guild = e.message.guild;
          commandContext.message = e.message;
          commandContext.author = e.message.author;
          commandContext.channel = e.message.channel;

          var newInstance = reflect(commandContext);
          newInstance.invoke(matched.simpleName, params);
        } catch (err) {
          _commandExecutionFailController
              .add(new CommandExecutionFailEvent._new(e.message, err));
        }

        logger.fine("Command executed");
        break;
    }
  }

  /// Register new [CommandContext] object.
  void add(CommandContext command) {
    var inst = reflect(command);
    var cls = inst.type;
    var cmd = _getCmdAnnot(cls, Command) as Command;

    command.logger = new Logger.detached("Command[${cmd.name}]");

    _commands.add(command);
    logger.info("Command[${cmd.name}] added to registry");
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
        throw new Exception("Service constructor not satisfied!");
      }
    });
  }

  /// Register commands in current Isolate's libraries. Basically loads all classes as commnads with [MirrorsCommand] superclass.
  /// Performs dependency injection when instantiate commands. And throws [Exception] when there are missing services
  void registerLibraryCommands() {
    _registerLibrary(CommandContext, (toInject, cm) {
      try {
        var cmd = cm.newInstance(new Symbol(''), toInject).reflectee;
        cmd.logger = new Logger.detached("Command");
        add(cmd);
      } catch (e) {
        print(e);
        throw new Exception("Command constructor not satisfied!");
      }
    });
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(String requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    for (var cmd in _commands)
      cmd.getHelp(_isUserAdmin(requestedUserId), buffer);

    return buffer.toString();
  }

  List<String> _groupParams(List<String> splitted) {
    var tmpList = new List();
    var isInto = false;

    var finalList = new List();

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

  List<String> _collectParams(
      MethodMirror method, List<String> splitted, Message e) {
    var params = method.parameters;
    splitted = _groupParams(splitted);

    List<Object> collected = new List();
    var index = -1;

    bool parsePrimitives(Type type) {
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
            collected.add(e.guild.channels[id]);
          } catch (e) {}
          break;
        case User:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.client.users[id]);
          } catch (e) {}
          break;
        case Role:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.roles[id]);
          } catch (e) {}
          break;
        case GuildEmoji:
          try {
            var id = _entityRegex.firstMatch(splitted[index]).group(3);
            collected.add(e.guild.emojis[id]);
          } catch (e) {}
          break;
        default:
          if (_typeConverters == null) return false;

          for (var converter in _typeConverters) {
            var t = converter.parse(splitted[index], e);
            if (t != null) {
              collected.add(t);
              return true;
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

      if (!parsePrimitives(type)) {
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

  bool _isUserAdmin(String authorId) {
    return (_admins != null && _admins.any((i) => i == authorId));
  }
}
