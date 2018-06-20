import 'package:nyxx/discord.dart' as discord;
import 'package:nyxx/vm.dart' as discord;

import 'dart:io';

void main() {
  discord.configureDiscordForVM();
  discord.Client bot =
      new discord.Client(Platform.environment['DISCORD_TOKEN']);

  var commands = new discord.Commands('!', bot, ["302359032612651009"])
    ..addMany([new PongCommand(), new EchoCommand()]);
}

class PongCommand extends discord.Command {
  PongCommand() : super("ping", "Checks if bot is connected!", "!ping");

  @override
  run(discord.Message message) async {
    await message.channel.sendMessage(content: "Pong!");
  }
}

class EchoCommand extends discord.Command {
  EchoCommand()
      : super(
            "echo", "Echoes bot message!", "!echo <message>", false);

  @override
  run(discord.Message message) async {
    await message.channel.sendMessage(content: message.content);
  }
}
