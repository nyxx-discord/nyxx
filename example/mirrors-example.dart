import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

import 'dart:io';
import 'dart:async';

// Example service which can be injected into your command handler
class Service {
  String data;

  Service(this.data);
}

// Main function
void main() {
  // Setup bot for VM
  setup.configureDiscordForVM();

  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Register new command handler.
  // It registers your services and adds command to registry.
  var commands =
      new command.MirrorsCommandFramework('!', bot, ["302359032612651009"])
        ..registerServices([new Service("Siema")])
        ..registerLibraryCommands();
}

// Example command with alias and subcommands.
class AliasCommand extends command.MirrorsCommand {
  Service _service;

  // Setting up basic bot info
  AliasCommand(this._service) {
    this.name = "alias";
    this.help = "Example of aliases";
    this.usage = "!alias or !aaa";
    this.aliases = ["aaa"];
  }

  // Maincommand annotation specifies main command handler
  @command.Maincommand()
  main(String name) async {
    await reply(content: name);
    await reply(content: _service.data);
  }

  // This command features `nextMessages()` method. Reade more here:
  // 
  @command.Subcommand("witam")
  witam() async {
    var messages = await nextMessages(2);
    print(messages);
  }

  // You can use customized logger instance
  @command.Subcommand("yyy")
  Future yyy(String siema, int witam) {
    logger.fine(siema);
    logger.severe(witam);
  }
}
