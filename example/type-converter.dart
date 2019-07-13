import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/commands.dart';

import 'dart:io';
import 'dart:async';

// Example `service` to convert message to
class Ex {
  String gg;

  Ex(this.gg);
}

// Example converter
class ExConverter extends TypeConverter<Ex> {
  ExConverter();

  // Logic for converting String message to your type.
  // Return null if converting isn't successful.
  @override
  Future<Ex> parse(String from, Message msg) async => Ex(from);
}

// Main function
void main() {
  // Create new bot instance
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  CommandsFramework(bot, prefix: '!', admins: [Snowflake("302359032612651009")])
    // You can register type converter by hand
    ..registerTypeConverters([ExConverter()])
    ..discoverCommands();
}

@Command("ping")
Future<void> pingCmd(CommandContext ctx, Ex ex) async =>
    await ctx.reply(content: ex.gg);
