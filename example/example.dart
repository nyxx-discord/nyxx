import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/commands.dart';

import 'dart:io';
import 'dart:async';

// Example service which can be injected into your command handler
class Service {
  String data;

  Service(this.data);
}

// Main function
void main() {
  configureNyxxForVM();

  // Create new bot instance
  Nyxx bot = Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Register new command handler.
  // It registers your services and adds command to registry.
  CommandsFramework(bot,
      prefix: '!', admins: [Snowflake("302359032612651009")])
    ..registerServices([Service("Siema")])
    ..discoverCommands();
}

@Command("alias", aliases: ['aaa'])
Future<void> aliasCmd(CommandContext ctx, String name) async {
  await ctx.reply(content: name);
}
