part of nyxx.commands;

/// Uses 'dart:mirrors' to find and dispatch commands. First searches in normal mode for matching command and next with 'mirros'
/// searches if command has subcommand and possibly runs it. Uses [Subcommand] to annotate subcommand function.
class MirrorsCommandFramework extends Commands {
  /// Main constructor - creates new instance of CommandsFramewok
  /// All arguments are passed back to [Commands]
  MirrorsCommandFramework(String prefix, Client client,
      [List<String> admins, String gameName])
      : super(prefix, client, admins, gameName);

  List<Object> services = new List();

  void registerServices(List<Object> services) => this.services = services;
  
  @override
  Future<Null> executeCommand(Message msg, Command matchedCommand) async {
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

  Future<Null> _reflectCommand(Message msg, Command command) async {
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

    if(matched == null) return null;
    
    //print("PASSED MATCHING");
    
    var params = _collectParams(matched, splitted);
    //return null;
    //if (params == null) return null;
    //print("PASSED MATCHING");

    try {
      instanceMirror.invoke(matched.simpleName, params);
    } catch (e) {
      throw new Exception("Cannot invoke method while parameters isn't satisfied!");
    }
    return null;
  }

  List<String> _collectParams(MethodMirror method, List<String> splitted) {
    var params = method.parameters;
    //print(params);

    List<Object> colllected = new List();
    var index = -1;
    
    params.forEach((e) {
      var type = e.type.reflectedType;
      if(type == String) {
        index++;

        try {
          colllected.add(splitted[index]);
        }
        catch (e) {
        }
      } else {
        services.forEach((s) {
          if(s.runtimeType == type) {
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
