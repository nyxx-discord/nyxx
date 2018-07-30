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

  // For now converter must implement method which returns a type of converter.
  // Working on high performance fix for this
  @override
  Type getType() => Ex;

  // Logic for converting String message to your type.
  // Return null if converting isn't successful.
  @override
  Ex parse(String from, nyxx.Message msg) {
    return new Ex(from);
  }
}

// Main function
void main() {
  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  new command.CommandsFramework('!', bot)
    .. admins = ["302359032612651009"]
    ..registerTypeConverters([new ExConverter()])
    ..registerLibraryCommands();
}

// Command have to extends CommandContext class and have @Command annotation.
// Method with @Maincommand is main point of command object
// Methods annotated with @Subcommand are defined as subcommands
@command.Command("ping")
class PongCommand extends command.CommandContext {

  // Accepting Ex instance as parameter. Argument will be converter to Ex.
  @command.Maincommand()
  Future run(Ex ex) async {
    await reply(content: ex.gg);
  }

  @override
  void getHelp(bool isAdmin, StringBuffer buffer) =>
      buffer.writeln("* ping - Returns ex.");
}
