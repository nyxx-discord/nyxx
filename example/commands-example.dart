import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

import 'dart:io';

void main() {
  setup.configureDiscordForVM();
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  var commands = new command.Commands('!', bot, ["302359032612651009"])
    ..addMany([new PongCommand(), new EchoCommand(), new AliasCommand()]);
}

class PongCommand extends command.Command {
  PongCommand() : super("ping", "Checks if bot is connected!", "!ping");

  @override
  run(nyxx.Message message) async {
    await message.channel.sendMessage(content: "Pong!");
  }
}

class EchoCommand extends command.Command {
  EchoCommand() : super("echo", "Echoes bot message!", "!echo <message>");

  @override
  run(nyxx.Message message) async {
    await message.channel.sendMessage(content: message.content);
  }
}

class AliasCommand extends command.Command {
  AliasCommand()
      : super("alias", "Example of aliases", "!alias or !aaa",
            aliases: ["aaa"]);

  @override
  run(nyxx.Message message) async {
    await message.channel.sendMessage(content: message.content);
  }
}
