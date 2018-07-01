part of nyxx;

/// Dispatches commands based on registry. [Command] class can only dispatch one command and aliases and dont have suncommand support.
/// It's faster than [MirrorsCommandFramework] because it isn't searching for matching methods at runtime.
class InstanceCommandFramework extends Commands {
  InstanceCommandFramework(String prefix, Client client, [List<String> admins, String gameName]) : super(prefix, client, admins, gameName);

  @override
  Future<Null> executeCommand(Message msg, Command matchedCommand) async {
    await matchedCommand.run(msg);
    return null;
  }
}