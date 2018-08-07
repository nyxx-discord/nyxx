part of nyxx.commands;

class Command {
  /// Name of command. Text which will trigger execution
  final String name;

  /// List of aliases for command
  final List<String> aliases;

  /// True if command should be main
  final bool main;

  const Command ({this.name, this.aliases, this.main});
}

class Cons {
  /// Indicates if commands is restricted to admins
  final bool isAdmin;

  /// List of roles required to execute command
  final List<Role> requiredRoles;

  /// List of required permissions to invoke command
  final List<int> requiredPermissions;

  /// Cooldown for command in seconds
  final int cooldown;

  /// Indicated if command is hidden from help
  final bool isHidden;

  /// Indicates if command can be executed in Guild, DM or both.
  final int guildOnly;

  /// If command is nsfw
  final bool isNsfw;

  /// Topic of command. Can only execute this command if channel has specific topics indicated
  /// Adding to channel topic `[games, PC]` will allow to only execute commands annotated with this phrases
  final List<String> topics;

  const Cons({this.isAdmin = false,
      this.requiredRoles,
      this.cooldown,
      this.isHidden = false,
      this.requiredPermissions,
      this.guildOnly,
      this.isNsfw,
      this.topics});
}

/// Captures all remaining text into `List<String>`
class Remainder {
  const Remainder();
}

class GuildOnly {
  /// Allows commands to be used only in DM
  static const int DM = 1 << 0;

  /// Allows commands to be used only in Guild
  static const int GUILD = 1 << 1;

  /// Allows commands to be used in both DM and Guild
  static const int BOTH = 1 << 2;
}
