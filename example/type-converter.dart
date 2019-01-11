import 'package:nyxx/Vm.dart';
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
  Future<Ex> parse(String from, nyxx.Message msg) async => Ex(from);
}

// Main function
void main() {
  configureNyxxForVM();

  // Create new bot instance
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  command.CommandsFramework(bot,
      prefix: '!', admins: [nyxx.Snowflake("302359032612651009")])
    // You can register type converter by hand
    ..registerTypeConverters([ExConverter()])
    ..discoverCommands();
}

@command.Command("ping")
Future<void> pingCmd(command.CommandContext ctx, Ex ex) async =>
    await ctx.reply(content: ex.gg);
