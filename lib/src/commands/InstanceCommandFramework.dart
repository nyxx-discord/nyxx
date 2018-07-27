part of nyxx.commands;

/// Dispatches commands based on registry. [Command] class can only dispatch one command and aliases and dont have suncommand support.
/// It's faster than [MirrorsCommandFramework] because it isn't searching for matching methods at runtime.
class InstanceCommandFramework extends Commands {
  InstanceCommandFramework(String prefix, Client client,
      [List<String> admins, String gameName])
      : super(prefix, client, admins, gameName);

  @override
  Future<Null> executeCommand(
      Message msg, AbstractCommand matchedCommand) async {
    await (matchedCommand as Command).run();
    return null;
  }

  @override

  /// Creates help String based on registered commands metadata.
  String createHelp(Snowflake requestedUserId) {
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
}
