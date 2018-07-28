part of nyxx.commands;

class Command {
  /// Name of command. Text which will trigger execution
  final String name;

  /// List of aliases for command
  final List<String> aliases;

  const Command(this.name, {this.aliases});
}

class AnnotCommand {
  /// Name of command
  final String cmd;

  /// Indicates if commands is restricted to admins
  final bool isAdmin;

  /// List of roles required to execute command
  final List<Role> requiredRoles;

  /// List of
  final List<int> requiredPermissions;

  /// Cooldown for command in seconds
  final int cooldown;

  /// Indicated if command is hidden from help
  final bool isHidden;

  const AnnotCommand(this.cmd,
      [this.isAdmin = false,
      this.requiredRoles = null,
      this.cooldown,
      this.isHidden = false,
      this.requiredPermissions = null]);
}

/// Defines new subcommand.
class Subcommand extends AnnotCommand {
  const Subcommand(String cmd,
      {bool isAdmin, List<Role> requiredRoles, int cooldown, bool isHidden, List<int> requiredPermissions})
      : super(cmd, isAdmin, requiredRoles, cooldown, isHidden, requiredPermissions);
}

/// Creates main execution command
class Maincommand extends AnnotCommand {
  const Maincommand(
      {bool isAdmin, List<Role> requiredRoles, int cooldown, bool isHidden, List<int> requiredPermissions})
      : super("", isAdmin, requiredRoles, cooldown, isHidden, requiredPermissions);
}

/// Captures all remaining text into `List<String>`
class Remainder {
  const Remainder();
}
