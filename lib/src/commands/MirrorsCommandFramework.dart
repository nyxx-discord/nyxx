part of nyxx;

class MirrorsCommandFramework extends Commands {
  MirrorsCommandFramework(String prefix, Client client, [List<String> admins, String gameName]) : super(prefix, client, admins, gameName);

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
  
  // Searches for command in registry.
  // Splits up command and gets first word (command). Then searchies in command registry and command's aliases list
  Iterable<Command> _getCommand(String msg) {
    var command = msg.split(' ')[0].replaceFirst(prefix, "");

    return _commands.where((i) =>
        command == i.name ||
        (i.aliases != null && i.aliases.contains(command)));
  }

  Future<Null> _reflectCommand(Message msg, Command command) async {
    var instanceMirror = reflect(command);
    var classMirror = instanceMirror.type;
    var methods = classMirror.declarations;

    var matched = null;
    var subcommand = null;
    var splitted = msg.content.split(' ');

    if(splitted.length > 1)
      subcommand = splitted[1];
    else {
      await command.run(msg);
      return null;
    }

    methods.forEach((k, v) {
      if(v is MethodMirror) {        
        var meta = _getCmdAnnot(v);

        if(meta != null && meta.cmd == subcommand)
          matched = v;
      }
    });
    
    if(matched == null) {
      await command.run(msg);
      return null;
    }
    
    instanceMirror.invoke(matched.simpleName, [msg]);
    return null;
  }
  
  Subcommand _getCmdAnnot(DeclarationMirror declaration) {
    for (var instance in declaration.metadata) {
      if (instance.hasReflectee) {
        var reflectee = instance.reflectee;
        if (reflectee.runtimeType == Subcommand) {
          return reflectee as Subcommand;
        }
      }
    }
    return null;
  }
}

/// Defines new subcommand.
class Subcommand {

  /// Name of command
  final String cmd;

  //// Const constructor
  const Subcommand(this.cmd);
}