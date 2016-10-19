part of discord;

/// A command for the command client.
abstract class Command {
  /// Whether or not the command is enabled.
  bool enabled;

  /// Whether or not to only trigger the command in a guild.
  bool guildOnly;

  /// Aliases for the command.
  List<String> aliases;

  /// The command name.
  String name;

  /// The command discription.
  String description;

  /// A usage example.
  String usage;

  /// Args for the command.
  List<Argument> args;

  void run(Client bot, Message msg, Map<String, dynamic> args);
}
