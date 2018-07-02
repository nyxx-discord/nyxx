part of nyxx.commands;

/// Absctract class to factory new command
abstract class Command {
  /// Name of command. Text which will trigger execution
  String name;

  /// Help message
  String help;

  /// Example usage of command
  String usage;

  /// Indicates if commands is restricted to admins
  bool isAdmin = false;

  /// List of roles required to execute command
  List<String> requiredRoles = null;

  /// Cooldown for command in seconds
  int cooldown = 0;

  /// Indicated if command is hidden from help
  bool isHidden = false;

  /// List of aliases for command
  List<String> aliases = null;

  /// Function which will be invoked when command triggers
  Future run();

  MessageEvent context;

  Future<MessageEvent> delay(
      {String prefix: "", bool ensureUser = false}) async {
    return await context.message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == context.message.author.id;

      return true;
    }).timeout(const Duration(seconds: 30),
        onTimeout: () => print("Timed out"));
  }
}
