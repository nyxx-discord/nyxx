part of nyxx.commands;

/// Defines command. Can be placed above method or class.
/// If places above class this means that class is group of commands and all
/// commans will be have prefix with given name.
/// Placed on method it defines command handler for specified command.
///
/// Code above cretaes new command group with name `cmd` and subcommand `check`.
/// Group also has default command handler if only `cmd` invoked
/// ```
/// @Command(name: "cmd")
/// class ExampleCommand {
///   // Invoked when message == `!cmd`
///   @Command(main: true)
///   Future main() async {
///    await reply(content: "Some reply");
///   }
///
///   // This is subcommand and will be invoked when message
///   // is equal with `!cmd check`
///   @Command(name: "check")
///   Future main() async {
///     await reply(content: "Checked!");
///   }
/// }
/// ```
class Command {
  /// Name of command. Text which will trigger execution
  final String name;

  /// List of aliases for command
  final List<String> aliases;

  /// True if command should be main
  final bool main;

  const Command({this.name, this.aliases: const [], this.main});
}

/// Defines additional properties which will restrict user access to command
/// All fields are optional and wont affect command execution of not set.
class Restrict {
  /// Checks if user is in admins list provided at creating CommandsFramework
  final bool admin;

  /// Checks if user is server owner
  final bool owner;

  /// List of roles required to execute command
  final List<Snowflake> roles;

  /// List of required permissions to invoke command
  final List<int> userPermissions;

  final List<int> botPermissions;

  /// Cooldown for command in seconds
  final int cooldown;

  /// Allows to restrict command to be used only on guild or only in DM or both
  final bool guild;

  /// If command is nfsw it wont be invoked in no nsfw channels
  final bool nsfw;

  /// Topic of command. Can only execute this command if channel has specific topics indicated
  /// Adding to channel topic `[games, PC]` will allow to only execute commands annotated with this phrases
  final List<String> topics;

  const Restrict(
      {this.admin,
      this.owner,
      this.roles,
      this.cooldown,
      this.userPermissions,
      this.botPermissions,
      this.guild,
      this.nsfw,
      this.topics});
}

/// Captures all remaining text into `List<String>` or `String`
class Remainder {
  const Remainder();
}
