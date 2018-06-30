part of nyxx;

/// Dispatches commands based on registry. [Command] class can only dispatch one command and aliases and dont have suncommand support.
/// It's faster than [MirrorsCommandFramework] because it isn't searching for matching methods at runtime.
class InstanceCommandFramework extends Commands {
  InstanceCommandFramework(String prefix, Client client, [List<String> admins, String gameName]) : super(prefix, client, admins, gameName);

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
        await matchedCommand.run(e.message);
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
}