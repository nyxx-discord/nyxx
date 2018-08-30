part of nyxx.commands;

class CommandMetadata {
  MethodMirror method;
  ObjectMirror parent;

  Restrict classRestrict;
  Command classCommand;

  Restrict methodRestrict;
  Command methodCommand;

  CommandMetadata(this.method, this.parent, this.classRestrict,
      this.classCommand, this.methodCommand, this.methodRestrict);

  bool get _classEnclosed => parent is ClassMirror;
  List<List<String>> get commandString {
    if (classCommand != null) if (methodCommand.main != null &&
        methodCommand.main)
      return [List.from(classCommand.aliases)..add(classCommand.name)];
    else
      return [
        List.from(classCommand.aliases)..add(classCommand.name),
        List.from(methodCommand.aliases)..add(methodCommand.name)
      ];

    return [List.from(methodCommand.aliases)..add(methodCommand.name)];
  }
}

T _getCmdAnnot<T>(DeclarationMirror declaration) {
  for (var instance in declaration.metadata) {
    if (instance.hasReflectee) {
      var reflectee = instance.reflectee;
      if (reflectee.runtimeType == T) {
        return reflectee as T;
      }
    }
  }
  return null;
}

/// Main point of commands in nyx.
/// It gets all sent messages and matches to registered command and invokes
/// its action.
class CommandsFramework {
  List<CommandMetadata> _commands;

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
    _client.onReady.listen((_) {
      _client.onMessage.listen((MessageEvent e) async {
        if (ignoreBots && e.message.author.bot) return;
        if (!e.message.content.startsWith(prefix)) return;

        await _dispatch(e);
      });
    });
  }

  /*
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
*/

  /// Allows to register new converters for custom type
  void registerTypeConverters(List<TypeConverter> converters) =>
      _typeConverters = converters;

  /// Register services to injected into commands modules. Has to be executed before registering commands.
  /// There cannot be more than 1 dependency with single type. Only first will be injected.
  void registerServices(List<Object> services) =>
      this._services.addAll(services);

  /// Register all services in current isolate. It captures all classes which inherits from [Service] class and performs dependency injection if possible.
  void registerLibraryServices() {
    var superClass = reflectClass(Service);
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

            try {
              var serv = cm.newInstance(new Symbol(''), toInject).reflectee;
              _services.add(serv);
            } catch (e) {
              throw new Exception(
                  "Service [${util.getSymbolName(cm.simpleName)}] constructor not satisfied!");
            }
          }
        }
      });
    });
  }

  /// Register commands in current Isolate's libraries. Basically loads all classes as commnads with [CommandContext] superclass.
  /// Performs dependency injection when instantiate commands. And throws [Exception] when there are missing services
  void registerLibraryCommands() {
    var mirrorSystem = currentMirrorSystem();

    mirrorSystem.libraries.forEach((_, library) {
      library.declarations.values.forEach((d) {
        var commandAnnot = _getCmdAnnot<Command>(d);

        if (commandAnnot != null) {
          if (d is ClassMirror) {
            d.declarations.values.forEach((f) {
              if (f is MethodMirror) {
                var methodCommandAnnot = _getCmdAnnot<Command>(f);

                if (methodCommandAnnot != null) {
                  var classRestrict = _getCmdAnnot<Restrict>(d);
                  var methodRestrict = _getCmdAnnot<Restrict>(f);

                  _commands.add(new CommandMetadata(f, d, classRestrict,
                      commandAnnot, methodCommandAnnot, methodRestrict));
                }
              }
            });
          } else if (d is MethodMirror) {
            var commandAnnot = _getCmdAnnot<Command>(d);

            if (commandAnnot != null) {
              var methodRestrict = _getCmdAnnot<Restrict>(d);

              _commands.add(new CommandMetadata(
                  d, library, null, null, commandAnnot, methodRestrict));
            }
          }
        }
      });
    });

    // Insert 2 keyword messages first
    _commands.sort((first, second) =>
        -first.commandString.length.compareTo(second.commandString.length));
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(Snowflake requestedUserId) {
    var buffer = new StringBuffer();

    buffer.writeln("**Available commands:**");

    //for (var cmd in _commands)
    //  cmd.getHelp(_isUserAdmin(requestedUserId), buffer);

    return buffer.toString();
  }

  Restrict _patchRestrictions(Restrict top, Restrict meth) {
    if (top == null && meth == null)
      return new Restrict();
    else if (top == null)
      top = new Restrict();
    else if (meth == null) meth = new Restrict();

    var admin = meth.admin != null ? meth.admin : top.admin;
    var owner = meth.owner != null ? meth.owner : top.owner;

    List<Snowflake> roles;
    if (meth.roles != null) {
      if (top.roles != null)
        roles = new List.from(top.roles)..addAll(meth.roles);
      else
        roles = meth.roles;
    }

    List<int> userPermissions;
    if (meth.userPermissions != null) {
      if (top.userPermissions != null)
        userPermissions = new List.from(top.userPermissions)
          ..addAll(meth.userPermissions);
      else
        userPermissions = meth.userPermissions;
    }

    List<int> botPermissions;
    if (meth.botPermissions != null) {
      if (top.botPermissions != null)
        botPermissions = new List.from(top.botPermissions)
          ..addAll(meth.botPermissions);
      else
        botPermissions = meth.botPermissions;
    }

    var cooldown = meth.cooldown != null ? meth.cooldown : top.cooldown;
    var guild = meth.guild != null ? meth.guild : top.guild;
    var nsfw = meth.nsfw != null ? meth.nsfw : top.nsfw;

    return new Restrict(
        admin: admin,
        owner: owner,
        roles: roles,
        userPermissions: userPermissions,
        botPermissions: botPermissions,
        cooldown: cooldown,
        guild: guild,
        nsfw: nsfw);
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

    var s = new Stopwatch()..start();

    var splittedCommand = _escapeParameters(
        e.message.content.replaceFirst(prefix, "").trim().split(' '));

    CommandMetadata matchedMeta;
    try {
      matchedMeta = _commands.firstWhere((test) {
        var cmdstr = test.commandString;

        if (cmdstr.length == 2) {
          if (cmdstr.first.contains(splittedCommand.first) &&
              (splittedCommand.length > 1 &&
                  cmdstr.last.contains(splittedCommand[1]))) return true;

          return false;
        } else {
          if (cmdstr.first.contains(splittedCommand.first)) return true;

          return false;
        }
      });
    } catch (err) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    var executionCode = await checkPermissions(matchedMeta, e.message);

    // Switch between execution codes
    switch (executionCode) {
      case 0:
        _forAdminOnlyEventController.add(e.message);
        break;
      case 1:
      case 6:
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
      case 7:
        _requiredTopicError.add(e.message);
        break;
      case -1:
      case -2:
      case 100:
        new Future(() async {
          try {
            splittedCommand.removeRange(0, matchedMeta.commandString.length);
            var methodInj = await _injectParameters(
                matchedMeta.method, splittedCommand, e.message);

            if (matchedMeta.parent is ClassMirror) {
              var cm = matchedMeta.parent as ClassMirror;

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

              var instance = cm.newInstance(new Symbol(''), toInject);

              instance.setField(new Symbol("guild"), e.message.guild);
              instance.setField(new Symbol("message"), e.message);
              instance.setField(new Symbol("author"), e.message.author);
              instance.setField(new Symbol("channel"), e.message.channel);
              instance.setField(new Symbol("client"), this._client);
              instance.invoke(matchedMeta.method.simpleName, methodInj);
            }

            if (matchedMeta.parent is LibraryMirror) {
              var context = new CommandContext._new(e.message.channel,
                  e.message.author, e.message.guild, _client);
              matchedMeta.parent.invoke(
                  matchedMeta.method.simpleName,
                  new List()
                    ..add(context)
                    ..addAll(methodInj));
            }
          } catch (err, stacktrace) {
            _commandExecutionFailController
                .add(new CommandExecutionFailEvent._new(e.message, err));
            logger.severe("ERROR OCCURED WHEN INVOKING COMMAND \n $stacktrace");
          }
        });

        logger.fine(
            "Command -${matchedMeta?.classCommand?.name?.toString()} ${matchedMeta?.methodCommand?.name?.toString()}- executed");
        break;
    }
  }

  Future<int> checkPermissions(CommandMetadata meta, Message e) async {
    int executionCode = -1;
    var annot = _patchRestrictions(meta.classRestrict, meta.methodRestrict);

    // Check if command requires admin
    if (executionCode == -1 && annot.admin != null && annot.admin)
      executionCode = _isUserAdmin(e.author.id) ? 100 : 0;

    // Check if command requires server owner
    if (executionCode == -1 && annot.owner != null && annot.owner)
      executionCode = e.guild.ownerID == e.author.id ? 100 : 0;

    //Check if user is on cooldown
    if (executionCode == -1) {
      if (annot.cooldown != null &&
          annot.cooldown >
              0) if (!(await _cooldownCache.canExecute(
          e.author.id,
          "${meta.classCommand.name}${meta.methodCommand.name}",
          annot.cooldown * 1000))) executionCode = 2;
    }

    var member = await e.guild.getMember(e.author);

    // Check if there is need to check user roles
    if (executionCode == -1 && annot.roles != null) {
      var hasRoles =
          member.roles.map((f) => f.id).where((t) => annot.roles.contains(t));

      if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
    }

    // Check if user has required permissions
    if (executionCode == -1 && annot.userPermissions != null) {
      var total = await member.getTotalPermissions();
      for (var perm in annot.userPermissions) {
        if ((total.raw | perm) == 0) {
          executionCode = 1;
          break;
        }
      }
    }

    // Check for channel compatibility
    if (executionCode == -1 && annot.guild != null && annot.guild) {
      if (!(e.channel is TextChannel)) executionCode = 3;
    }

    // Check for channel nsfw
    if (executionCode == -1 && annot.nsfw != null && annot.nsfw) {
      if (e.channel is TextChannel) {
        var ch = e.channel as TextChannel;
        if (ch.nsfw == null)
          executionCode = 4;
        else if (!ch.nsfw) executionCode = 4;
      } else if (!(e.channel is DMChannel) || !(e.channel is GroupDMChannel))
        executionCode = 4;
    }

    // Check for channel topics
    if (executionCode == -1 &&
        annot.topics != null &&
        e.channel is TextChannel) {
      var topic = (e.channel as TextChannel).topic;
      var list = topic
          .substring(topic.indexOf("[") + 1, topic.indexOf("]"))
          .split(",")
          .map((f) => f.trim());

      var total = false;
      for (var topic in annot.topics) {
        if (list.contains(topic)) {
          total = true;
          break;
        }
      }

      if (!total) executionCode = 5;
    }

    // Check if bot has required permissions
    if (executionCode == -1 && annot.userPermissions != null) {
      var total =
          await (await e.guild.getMember(_client.user)).getTotalPermissions();
      for (var perm in annot.userPermissions) {
        if ((total.raw | perm) == 0) {
          executionCode = 6;
          break;
        }
      }
    }

    // Run check
    if (executionCode == -1 && annot.check != null && !annot.check(e))
      executionCode = 7;

    return executionCode;
  }

  // Groups params into
  List<String> _escapeParameters(List<String> splitted) {
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

  Future<List<Object>> _injectParameters(
      MethodMirror method, List<String> splitted, Message e) async {
    var params = method.parameters;

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

      if (_getCmdAnnot<Remainder>(e) != null) {
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

  bool _isUserAdmin(Snowflake authorId) {
    return (admins != null && admins.any((i) => i == authorId));
  }
}
