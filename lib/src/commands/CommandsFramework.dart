part of nyxx.commands;

/// Main point of commands in nyx.
/// It gets all sent messages and matches to registered command and invokes
/// its action.
class CommandsFramework {
  List<_CommandMetadata> _commands;

  List<TypeConverter> _typeConverters;
  CooldownCache _cooldownCache;
  List<Object> _services = List();
  Nyxx _client;

  StreamController<Message> _cooldownEvent;
  StreamController<Message> _commandNotFoundEvent;
  StreamController<Message> _requiredPermissionEvent;
  StreamController<Message> _forAdminOnlyEvent;
  StreamController<CommandExecutionFailEvent> _commandExecutionFail;
  StreamController<Message> _wrongContext;
  StreamController<Message> _unauthorizedNsfwAccess;
  StreamController<Message> _requiredTopicError;
  StreamController<PreprocessorErrorEvent> _preprocessorFail;
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
  set game(Presence game) => _client.user.setGame(game);

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

  /// Emitted when dispatch function fails when checking preprocessors
  Stream<PreprocessorErrorEvent> preprocessorFail;

  /// Emitted when command fails to parse. Eg. Wrong arguments
  //Stream<CommandParsingFail> onCommandParsingFail;

  /// Logger instance
  final Logger logger = Logger.detached("CommandsFramework");

  /// Creates commands framework handler. Requires prefix to handle commands.
  CommandsFramework(this.prefix, this._client,
      {Duration roundupTime = const Duration(minutes: 2)}) {
    this._commands = List();
    _cooldownCache = CooldownCache(roundupTime);

    _commandNotFoundEvent = StreamController.broadcast();
    _requiredPermissionEvent = StreamController.broadcast();
    _forAdminOnlyEvent = StreamController.broadcast();
    _cooldownEvent = StreamController.broadcast();
    _commandExecutionFail = StreamController.broadcast();
    _wrongContext = StreamController.broadcast();
    _unauthorizedNsfwAccess = StreamController.broadcast();
    _requiredTopicError = StreamController.broadcast();
    _preprocessorFail = StreamController.broadcast();
    //_commandParsingFail = new StreamController.broadcast();

    onCommandNotFound = _commandNotFoundEvent.stream;
    onAdminOnlyError = _forAdminOnlyEvent.stream;
    onRequiredPermissionError = _forAdminOnlyEvent.stream;
    onCooldown = _cooldownEvent.stream;
    onCommandExecutionFail = _commandExecutionFail.stream;
    onWrongContext = _wrongContext.stream;
    onUnauthorizedNsfwAccess = _unauthorizedNsfwAccess.stream;
    onRequiredTopicError = _requiredTopicError.stream;
    preprocessorFail = _preprocessorFail.stream;
    //onCommandParsingFail = _commandParsingFail.stream;

    // Listen to incoming messages and ignore all from bots (if set)
    _client.onReady.listen((_) {
      _client.onMessage.listen((MessageEvent e) {
        if (ignoreBots && e.message.author.bot) return;
        if (!e.message.content.startsWith(prefix)) return;

        Future.microtask(() => _dispatch(e));
      });
    });
  }

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
      for (var cm in lib.declarations.values) {
        if (cm is ClassMirror) {
          if (cm.isSubclassOf(superClass) && !cm.isAbstract) {
            var toInject = _createConstuctorInjections(cm);

            try {
              var serv = cm.newInstance(Symbol(''), toInject).reflectee;
              _services.add(serv);
            } catch (e) {
              throw Exception(
                  "Service [${util.getSymbolName(cm.simpleName)}] constructor not satisfied!");
            }

            break;
          }
        }
      }
    });
  }

  List<Object> _createConstuctorInjections(ClassMirror service) {
    var ctor = service.declarations.values.toList().firstWhere((m) {
      if (m is MethodMirror) return m.isConstructor;

      return false;
    }) as MethodMirror;

    var params = ctor.parameters;
    var toInject = List<dynamic>();

    for (var param in params) {
      for (var service in _services) {
        if (param.type.reflectedType == service.runtimeType || param.type.isAssignableTo(reflectType(service.runtimeType))) toInject.add(service);
      }
    }
    return toInject;
  }

  String _createLog(Module classCmd, Command methodCmd) =>
      "[${classCmd != null ? classCmd.name : ""}${methodCmd != null && (methodCmd.main == null || !methodCmd.main) ? " ${methodCmd.name}" : ""}]";

  List<List> _getProcessors(
      ClassMirror classMirror, DeclarationMirror methodMirror) {
    var classPre = <Preprocessor>[];
    var classPost = <Postprocessor>[];

    if (classMirror != null) {
      classPre.addAll(util.getCmdAnnots<Preprocessor>(classMirror));
      classPost.addAll(util.getCmdAnnots<Postprocessor>(classMirror));
    }

    var methodPre = util.getCmdAnnots<Preprocessor>(methodMirror);
    var methodPost = util.getCmdAnnots<Postprocessor>(methodMirror);

    var prepro = List<Preprocessor>.from(classPre)
      ..addAll(methodPre)
      ..removeWhere((e) => e == null);
    var postPro = List<Postprocessor>.from(classPost)
      ..addAll(methodPost)
      ..removeWhere((e) => e == null);

    return [prepro, postPro];
  }

  /// Register commands in current Isolate's libraries. Basically loads all classes as commnads with [CommandContext] superclass.
  /// Performs dependency injection when instantiate commands. And throws [Exception] when there are missing services
  void registerLibraryCommands() {
    var mirrorSystem = currentMirrorSystem();

    mirrorSystem.libraries.forEach((_, library) {
      library.declarations.values.forEach((d) {
        var commandAnnot = util.getCmdAnnot<Module>(d);

        if (commandAnnot != null) {
          if (d is ClassMirror) {
            d.declarations.values.forEach((f) {
              if (f is MethodMirror) {
                var methodCommandAnnot = util.getCmdAnnot<Command>(f);

                if (methodCommandAnnot != null) {
                  var classRestrict = util.getCmdAnnot<Restrict>(d);
                  var methodRestrict = util.getCmdAnnot<Restrict>(f);
                  var methodHelp = util.getCmdAnnot<Help>(f);
                  var processors = _getProcessors(d, f);

                  _commands.add(_CommandMetadata(
                      f,
                      d,
                      classRestrict,
                      commandAnnot,
                      methodCommandAnnot,
                      methodRestrict,
                      methodHelp,
                      processors.first as List<Preprocessor>,
                      processors.last as List<Postprocessor>));
                  logger.fine(
                      "Command ${_createLog(commandAnnot, methodCommandAnnot)} has been registered");
                }
              }
            });
          } else if (d is MethodMirror) {
            var commandAnnot = util.getCmdAnnot<Command>(d);

            if (commandAnnot != null) {
              var methodRestrict = util.getCmdAnnot<Restrict>(d);
              var methodHelp = util.getCmdAnnot<Help>(d);
              var processors = _getProcessors(null, d);

              _commands.add(_CommandMetadata(
                  d,
                  library,
                  null,
                  null,
                  commandAnnot,
                  methodRestrict,
                  methodHelp,
                  processors.first as List<Preprocessor>,
                  processors.last as List<Postprocessor>));
              logger.fine(
                  "Command [${commandAnnot.name.toString()}] has been registered");
            }
          }
        }
      });
    });

    //Insert 2 keyword messages first
    _commands.sort((first, second) =>
        -first.commandString.length.compareTo(second.commandString.length));

    print(_commands.map((d) => d.commandString));
  }

  /// Creates help String based on registered commands metadata.
  String _createHelp(Snowflake requestedUserId, Guild guild) {
    var buffer = StringBuffer();
    buffer.writeln("**Available commands:**");

    var isAdmin = _isUserAdmin(requestedUserId, guild);
    for (var meta in _commands) {
      if (meta.methodHelp == null) continue;

      if ((meta.classRestrict != null &&
              meta.classRestrict.hidden &&
              isAdmin) ||
          (meta.methodRestrict != null &&
              meta.methodRestrict.hidden &&
              isAdmin)) continue;

      StringBuffer commandName = StringBuffer();

      if (meta.classCommand != null)
        commandName.write(
            "${meta.classCommand.name} ${meta.methodCommand.main != null ? "[main]" : meta.methodCommand.name}");
      commandName
          .write("${meta.methodCommand.name} ${meta.methodCommand.aliases}");

      buffer.write("\n **$commandName** \n\t ${meta.methodHelp.description}");

      if (meta.methodHelp.usage != null)
        buffer.write("\n\t *Usage:* ${this.prefix}${meta.methodHelp.usage}");
    }

    return buffer.toString();
  }

  Restrict _patchRestrictions(Restrict top, Restrict meth) {
    if (top == null && meth == null)
      return Restrict();
    else if (top == null)
      top = Restrict();
    else if (meth == null) meth = Restrict();

    var admin = meth.admin != null ? meth.admin : top.admin;
    var owner = meth.owner != null ? meth.owner : top.owner;

    List<Snowflake> roles = List.from(top.roles)..addAll(meth.roles);

    List<int> userPermissions = List.from(top.userPermissions)
      ..addAll(meth.userPermissions);
    List<int> botPermissions = List.from(top.botPermissions)
      ..addAll(meth.botPermissions);
    List<String> topics = List.from(top.topics)..addAll(meth.topics);

    var cooldown = meth.cooldown != null ? meth.cooldown : top.cooldown;
    var guild = meth.guild != null ? meth.guild : top.guild;
    var nsfw = meth.nsfw != null ? meth.nsfw : top.nsfw;

    return Restrict(
        admin: admin,
        owner: owner,
        roles: roles,
        userPermissions: userPermissions,
        botPermissions: botPermissions,
        cooldown: cooldown,
        guild: guild,
        nsfw: nsfw,
        topics: topics);
  }

  /// Dispatches onMessage event to framework.
  Future _dispatch(MessageEvent e) async {
    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith("${prefix}help")) {
      if (helpDirect) {
        e.message.author
            .send(content: _createHelp(e.message.author.id, e.message.guild));
        return;
      }

      await e.message.channel
          .send(content: _createHelp(e.message.author.id, e.message.guild));
      return;
    }

    var splittedCommand = _escapeParameters(
        e.message.content.replaceFirst(prefix, "").trim().split(' '));

    _CommandMetadata matchedMeta;
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
      _commandNotFoundEvent.add(e.message);
      return;
    }

    var executionCode = -1;

    if (matchedMeta.preprocessors.length > 0 &&
        !matchedMeta.preprocessors
            .every((pre) => pre.execute(_services, e.message)))
      executionCode = 8;

    if (matchedMeta.methodRestrict != null && matchedMeta.classRestrict != null)
      executionCode = await checkPermissions(matchedMeta, e.message);

    // Switch between execution codes
    switch (executionCode) {
      case 0:
        _forAdminOnlyEvent.add(e.message);
        break;
      case 1:
      case 6:
        _requiredPermissionEvent.add(e.message);
        break;
      case 2:
        _cooldownEvent.add(e.message);
        break;
      case 3:
        _wrongContext.add(e.message);
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
        dynamic res;
        //try {
          splittedCommand.removeRange(0, matchedMeta.commandString.length);
          var methodInj = await _injectParameters(
              matchedMeta.method, splittedCommand, e.message);

          if (matchedMeta.parent is ClassMirror) {
            var cm = matchedMeta.parent as ClassMirror;
            var toInject = _createConstuctorInjections(cm);

            var instance = cm.newInstance(Symbol(''), toInject);

            instance.setField(Symbol("guild"), e.message.guild);
            instance.setField(Symbol("message"), e.message);
            instance.setField(Symbol("author"), e.message.author);
            instance.setField(Symbol("channel"), e.message.channel);
            instance.setField(Symbol("client"), this._client);
            res = instance.invoke(matchedMeta.method.simpleName, methodInj);
          }

          if (matchedMeta.parent is LibraryMirror) {
            var context = CommandContext._new(e.message.channel,
                e.message.author, e.message.guild, _client, e.message);

            res = matchedMeta.parent.invoke(
                matchedMeta.method.simpleName,
                List()
                  ..add(context)
                  ..addAll(methodInj));
          }
        //} catch (err, stacktrace) {
        //  _commandExecutionFail
        //      .add(CommandExecutionFailEvent._new(e.message, err));
        //  res = err;
        //  logger.severe("ERROR OCCURED WHEN INVOKING COMMAND \n $err \n $stacktrace");
        //}

        if (matchedMeta.postprocessors.length > 0) {
          for (var post in matchedMeta.postprocessors)
            post.execute(
                _services,
                res is InstanceMirror && res.hasReflectee ? res.reflectee : res,
                e.message);
        }

        logger.fine(
            "Command ${_createLog(matchedMeta.classCommand, matchedMeta.methodCommand)} executed");
        break;
    }
  }

  Future<int> checkPermissions(_CommandMetadata meta, Message e) async {
    int executionCode = -1;
    var annot = _patchRestrictions(meta.classRestrict, meta.methodRestrict);

    // Check if command requires admin
    if (executionCode == -1 && annot.admin != null && annot.admin)
      executionCode = _isUserAdmin(e.author.id, e.guild) ? 100 : 0;

    // Check if command requires server owner
    if (executionCode == -1 && annot.owner != null && annot.owner)
      executionCode = e.guild.owner.id == e.author.id ? 100 : 0;

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
      var total = member.totalPermissions;
      for (var perm in annot.userPermissions) {
        if ((total.raw | perm) == 0) {
          executionCode = 1;
          break;
        }
      }
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
        (await e.guild.getMember(_client.user)).totalPermissions;
      for (var perm in annot.userPermissions) {
        if ((total.raw | perm) == 0) {
          executionCode = 6;
          break;
        }
      }
    }

    return executionCode;
  }

  // Groups params into
  List<String> _escapeParameters(List<String> splitted) {
    var tmpList = List<String>();
    var isInto = false;

    var finalList = List<String>();

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

  RegExp _entityRegex = RegExp(r"<(@|@!|@&|#|a?:(.+):)([0-9]+)>");

  Future<List<Object>> _injectParameters(
      MethodMirror method, List<String> splitted, Message e) async {
    var params = method.parameters;

    List<Object> collected = List();
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
          collected.add(e.guild.channels[Snowflake(id)]);
          break;
        case User:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.client.users[Snowflake(id)]);
          break;
        case Role:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.roles[Snowflake(id)]);
          break;
        case GuildEmoji:
          var id = _entityRegex.firstMatch(splitted[index]).group(3);
          collected.add(e.guild.emojis[Snowflake(id)]);
          break;
        case UnicodeEmoji:
          collected.add(util.emojisUnicode[splitted[index]..replaceAll(":", "")]);
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

      if (util.getCmdAnnot<Remainder>(e) != null) {
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
      } on Exception {}
    }

    return collected;
  }

  bool _isUserAdmin(Snowflake authorId, Guild guild) {
    return (admins != null && admins.any((i) => i == authorId)) ||
        guild.owner.id == authorId;
  }
}
