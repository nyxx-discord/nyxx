part of nyxx.commands;

/// Emitted when command execution fails
class CommandExecutionFailEvent {
  /// Message which caused error
  Message message;

  /// Error object
  Exception exception;

  CommandExecutionFailEvent._new(this.message, this.exception);
}

/// Uses 'dart:mirrors' to find and dispatch commands. First searches in normal mode for matching command and next with 'mirros'
/// searches if command has subcommand and possibly runs it. Uses [Subcommand] to annotate subcommand function.
class MirrorsCommandFramework extends Commands {
  /// Main constructor - creates new instance of CommandsFramewok
  /// All arguments are passed back to [Commands]
  MirrorsCommandFramework(String prefix, Client client,
      [List<String> admins, String gameName])
      : super(prefix, client, admins, gameName) {
    _commandExecutionFail = new StreamController<CommandExecutionFailEvent>();
    commandExecutionFail = _commandExecutionFail.stream;
  }

  List<Object> _services = new List();
  StreamController<CommandExecutionFailEvent> _commandExecutionFail;

  /// Emmited when command execution fails
  Stream<CommandExecutionFailEvent> commandExecutionFail;

  void registerServices(List<Object> services) => this._services = services;

  void registerLibraryCommands() {
    var superClass = reflectClass(MirrorsCommand);
    var mirrorSystem = currentMirrorSystem();

    mirrorSystem.libraries.forEach((uri, lib) {
      lib.declarations.forEach((s, decl) {
        if (decl is ClassMirror) {
          var cm = decl as ClassMirror;
          if (cm.isSubclassOf(superClass) && !cm.isAbstract) {
            var ctor = cm.declarations.values.toList().firstWhere((m) {
              if (m is MethodMirror) {
                var method = m as MethodMirror;

                return method.isConstructor;
              }
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

            print(toInject);

            try {
              super
                  ._commands
                  .add(cm.newInstance(new Symbol(''), toInject).reflectee);
            } catch (e) {
              throw new Exception("Command constructor not satisfied!");
            }
          }
        }
      });
    });
  }

  @override
  Future<Null> executeCommand(
      Message msg, AbstractCommand matchedCommand) async {
    await _reflectCommand(msg, matchedCommand);
    return null;
  }

  @override

  /// Creates help String based on registered commands metadata.
  String createHelp(String requestedUserId) {
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

  Future<Null> _reflectCommand(Message msg, AbstractCommand command) async {
    var instanceMirror = reflect(command);
    var classMirror = instanceMirror.type;
    var methods = classMirror.declarations;

    var matched = null;
    var subcommand = null;
    var splitted = msg.content.split(' ');

    if (splitted.length > 1) {
      subcommand = splitted[1];
      methods.forEach((k, v) {
        if (v is MethodMirror) {
          var meta = _getCmdAnnot(v, Subcommand) as Subcommand;

          if (meta != null && meta.cmd == subcommand) {
            matched = v;
            splitted.removeRange(0, 2);
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
            splitted.removeAt(0);
            return;
          }
        }
      });
    }

    if (matched == null) return null;
    var params = _collectParams(matched, splitted);

    try {
      instanceMirror.invoke(matched.simpleName, params);
    } catch (e) {
      _commandExecutionFail.add(new CommandExecutionFailEvent._new(msg, e));
    }
    return null;
  }

  List<String> groupParams(List<String> splitted) {
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

  List<String> _collectParams(MethodMirror method, List<String> splitted) {
    var params = method.parameters;
    //print(params);

    splitted = groupParams(splitted);

    List<Object> colllected = new List();
    var index = -1;

    params.forEach((e) {
      var type = e.type.reflectedType;
      if (type == String) {
        index++;

        try {
          colllected.add(splitted[index]);
        } catch (e) {}
      } else if (type == int) {
        index++;

        try {
          var d = int.parse(splitted[index]);
          colllected.add(d);
        } catch (e) {}
      } else if (type == double) {
        index++;

        try {
          var d = double.parse(splitted[index]);
          colllected.add(d);
        } catch (e) {}
      } else {
        _services.forEach((s) {
          if (s.runtimeType == type) {
            colllected.add(s);
          }
        });
      }
    });

    return colllected;
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
}
