import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

// Example `service` to convert message to
class Ex {
  String gg;

  Ex(this.gg);
}

// Example converter
class ExConverter extends command.TypeConverter<Ex> {
  ExConverter();

  // Logic for converting String message to your type.
  // Return null if converting isn't successful.
  @override
  Ex parse(String from, nyxx.Message msg) => Ex(from);
}

// Main function
void main() {
  // Create new bot instance
  nyxx.Client bot = nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  command.CommandsFramework('!', bot)
    ..admins = [const nyxx.Snowflake.static("302359032612651009")]
    // You can register type converter by hand
    ..registerTypeConverters([ExConverter()])
    ..registerLibraryCommands();
}

// Command have to extends CommandContext class and have @Command annotation.
// Method with @Maincommand is main point of command object
// Methods annotated with @Subcommand are defined as subcommands
@command.Command(name: "ping")
class PongCommand extends command.CommandContext {
  // Accepting Ex instance as parameter. Argument will be converter to Ex.
  @command.Command(main: true)
  Future run(Ex ex) async => await reply(content: ex.gg);

  @override
  void getHelp(bool isAdmin, StringBuffer buffer) =>
      buffer.writeln("* ping - Returns ex.");
}
