import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

// Main function
void main() {
  // Create new bot instance
  // Dart 2 introduces optional new keyword, so we can leave it
  nyxx.Client bot = nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands for first prefix.
  command.CommandsFramework('!', bot)
    ..add(PongCommand());

  // Registering second CommandsFramework with different prefix
  command.CommandsFramework(";;", bot)
    ..add(EchoCommand());
}

@command.Command(name: "ping")
class PongCommand extends command.CommandContext {
  @command.Command(main: true)
  Future run() async {
    await reply(content: "Pong!");
  }
}

@command.Command(name: "echo")
class EchoCommand extends command.CommandContext {
  @command.Command(main: true)
  Future run() async {
    await reply(content: message.content);
  }
}
