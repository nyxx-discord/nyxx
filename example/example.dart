import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

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
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Register new command handler.
  // It registers your services and adds command to registry.
  command.CommandsFramework(bot,
      prefix: '!', admins: [nyxx.Snowflake("302359032612651009")])
    ..registerServices([Service("Siema")])
    ..discoverCommands();
}
@command.Command("alias", aliases: ['aaa'])
Future<void> aliasCmd(command.CommandContext ctx, String name) async {
  await ctx.reply(content: name);
}