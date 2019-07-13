import 'package:nyxx/Vm.dart';
import 'package:nyxx/commands.dart';

import 'dart:io';
import 'dart:async';

// Main function
void main() {
  // Create new bot instance
  // Dart 2 introduces optional new keyword, so we can leave it
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  CommandsFramework(bot, prefix: '!', admins: [Snowflake("302359032612651009")])
    ..discoverCommands();
}

/// Example command preprocessor.
class IsGuildProcessor implements Preprocessor {
  const IsGuildProcessor();

  @override
  Future<PreprocessorResult> execute(
      List<Object> services, Message message) async {
    return message.guild != null
        ? PreprocessorResult.success()
        : PreprocessorResult.error("ERROR");
  }
}

class PrintString implements Postprocessor {
  final dynamic str;
  const PrintString(this.str);

  @override
  Future<void> execute(List<Object> services, returns, Message message) async {
    print("From postProcessor: $str");
  }
}

@Command("single")
@IsGuildProcessor()
@PrintString("This is string to print")
Future<void> single(CommandContext context) async {
  await context.reply(content: "WORKING");
}
