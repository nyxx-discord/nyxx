import 'package:nyxx/Vm.dart';
import 'package:nyxx/commands.dart';

import 'dart:io';
import 'dart:async';

void main() {
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  // Manual banchmark
  bot.onMessageReceived.listen((e) async {
    if (e.message.content == "!bm") {
      var msg = await e.message.channel.send(content: "Pong!");
      await msg.edit(
          content:
              "Total response time in 'manual way': ${msg.createdAt.difference(e.message.createdAt).inMilliseconds} ms");
    }
  });
  CommandsFramework(bot, prefix: "!")..discoverCommands();
}

// Commands banchmark.
@Command("bc")
Future<void> benchmark(CommandContext context) async {
  var msg = await context.reply(content: "Pong!");
  await msg.edit(
      content:
          "Total response time in 'command way': ${msg.createdAt.difference(context.message.createdAt).inMilliseconds} ms");
}
