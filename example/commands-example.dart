import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

import 'dart:io';

void main() {
  setup.configureDiscordForVM();
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  var commands =
      new command.InstanceCommandFramework('!', bot, ["302359032612651009"])
        ..addMany([new PongCommand(), new EchoCommand(), new AliasCommand()]);
}

class PongCommand extends command.Command {
  PongCommand() {
    this.name = "ping";
    this.help = "Checks if bot is connected!";
    this.usage = "!ping";
  }

  @override
  run() async {
    await context.message.channel.sendMessage(content: "Pong!");
  }
}

class EchoCommand extends command.Command {
  EchoCommand() {
    this.name = "echo";
    this.help = "Echoes bot message!";
    this.usage = "!echo <message>";
  }

  @override
  run() async {
    await context.message.channel.sendMessage(content: message.content);
  }
}

class AliasCommand extends command.Command {
  AliasCommand() {
    this.name = "alias";
    this.help = "Example of aliases";
    this.usage = "!alias or !aaa";
    this.aliases = ["aaa"];
  }

  @override
  run() async {
    await context.message.channel.sendMessage(content: message.content);
  }
}
