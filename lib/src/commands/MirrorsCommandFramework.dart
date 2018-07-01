part of nyxx;

class MirrorsCommandFramework extends Commands {
  MirrorsCommandFramework(String prefix, Client client, [List<String> admins, String gameName]) : super(prefix, client, admins, gameName);

    @override
  /// Dispatches onMessage event to framework.
  Future dispatch(MessageEvent e) async {
    if (!e.message.content.startsWith(prefix)) return;

    // Match help specially to shadow user defined help commands.
    if (e.message.content.startsWith((prefix + 'help'))) {
      if (helpDirect) {
        e.message.author.send(content: _createHelp(e.message.author.id));
        return;
      }

      await e.message.channel
          .sendMessage(content: _createHelp(e.message.author.id));
      return;
    }

    // Search for matching command in registry. If registry contains multiple commands with identical name - run first one.
    var commandCollection = _getCommand(e.message.content);

    // If there is no command - return
    if (commandCollection.isEmpty) {
      _commandNotFoundEventController.add(e.message);
      return;
    }

    // Get command and set execution code to default value;
    var matchedCommand = commandCollection.first;
    var executionCode = -1;

    // Check for admin command and if user is admin
    if (matchedCommand.isAdmin)
      executionCode = _isUserAdmin(e.message.author.id) ? 100 : 0;

    // Check if there is need to check user roles
    if (matchedCommand.requiredRoles != null && executionCode == -1) {
      var member = await e.message.guild.getMember(e.message.author);

      var hasRoles = matchedCommand.requiredRoles
          .where((i) => member.roles.contains(i))
          .toList();

      if (hasRoles == null || hasRoles.isEmpty) executionCode = 1;
    }

    //Check if user is on cooldown
    if (executionCode == -1 &&
        matchedCommand.cooldown >
            0) if (!(await _cooldownCache.canExecute(
        e.message.author.id,
        matchedCommand.name,
        matchedCommand.cooldown * 1000))) executionCode = 2;

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
      case -1:
      case 100:
        await _reflectCommand(e.message, matchedCommand);
        print("[INFO] Dispatched command successfully!");
        break;
    }
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
        var meta = getAnnotation(v, Subcommand) as Subcommand;

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
  
  Object getAnnotation(DeclarationMirror declaration, Type annotation) {
    for (var instance in declaration.metadata) {
      if (instance.hasReflectee) {
        var reflectee = instance.reflectee;
        if (reflectee.runtimeType == annotation) {
          return reflectee;
        }
      }
    }
    return null;
  }
}

class Subcommand {
  final String cmd;

  const Subcommand(this.cmd);
}