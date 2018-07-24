import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

import 'dart:io';

// Main function
void main() {
  // Setup bot for VM
  setup.configureDiscordForVM();

  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Creating new InstnceCommandFramework object and registering commands.
  var commands =
      new command.InstanceCommandFramework('!', bot, ["302359032612651009"])
        ..addMany([new PongCommand(), new EchoCommand(), new AliasCommand()]);
}

// Command have to extends Command class and override run() method.
// Run method is main point of command
class PongCommand extends command.Command {
  PongCommand() {
    this.name = "ping";
    this.help = "Checks if bot is connected!";
    this.usage = "!ping";
  }

  @override
  run() async {
    await reply(content: "Pong!");
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
    await reply(content: context.message.content);
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
    await reply(content: context.message.content);
  }
}
