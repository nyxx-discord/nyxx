part of nyxx.commands;

/// Uses 'dart:mirrors' to find and dispatch commands. First searches in normal mode for matching command and next with 'mirros'
/// searches if command has subcommand and possibly runs it. Uses [Subcommand] to annotate subcommand function.
class MirrorsCommandFramework extends Commands {
  /// Main constructor - creates new instance of CommandsFramewok
  /// All arguments are passed back to [Commands]
  MirrorsCommandFramework(String prefix, Client client,
      [List<String> admins, String gameName])
      : super(prefix, client, admins, gameName);

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

    if (splitted.length > 1)
      subcommand = splitted[1];
    else {
      await command.run();
      return null;
    }

    methods.forEach((k, v) {
      if (v is MethodMirror) {
        var meta = _getCmdAnnot(v);

        if (meta != null && meta.cmd == subcommand) matched = v;
      }
    });

    if (matched == null) {
      await command.run();
      return null;
    }

    instanceMirror.invoke(matched.simpleName, []);
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
