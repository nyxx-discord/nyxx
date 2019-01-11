import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

// Main function
void main() {
  configureNyxxForVM();
  // Create new bot instance
  // Dart 2 introduces optional new keyword, so we can leave it
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  command.CommandsFramework(bot,
      prefix: '!', admins: [nyxx.Snowflake("302359032612651009")])
    ..discoverCommands();
}

/// Example command preprocessor.
class IsGuildProcessor implements command.Preprocessor {
  const IsGuildProcessor();

  @override
  Future<command.PreprocessorResult> execute(
      List<Object> services, nyxx.Message message) async {
    return message.guild != null
        ? command.PreprocessorResult.success()
        : command.PreprocessorResult.error("ERROR");
  }
}

class PrintString implements command.Postprocessor {
  final dynamic str;
  const PrintString(this.str);

  @override
  Future<void> execute(List<Object> services, returns, nyxx.Message message) async {
    print("From postProcessor: $str");
  }
}

@command.Command("single")
Future<void> single(command.CommandContext context) async {
  await context.reply(content: "WORKING");
}