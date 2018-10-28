import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as cmd;

import 'dart:io';
import 'dart:async';

void main() {
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Manual banchmark
  bot.onMessageReceived.listen((nyxx.MessageReceivedEvent e) async {
    if (e.message.content == "!bm") {
      var msg = await e.message.channel.send(content: "Pong!");
      await msg.edit(
          content:
              "Total response time in 'manual way': ${msg.createdAt.difference(e.message.createdAt).inMilliseconds} ms");
    }
  });

  cmd.CommandsFramework(prefix: "!")
    ..discoverCommands();
}

// Commands banchmark.
@cmd.Command(name: "bc")
Future<void> benchmark(cmd.CommandContext context) async {
  var msg = await context.reply(content: "Pong!");
  await msg.edit(
      content:
          "Total response time in 'command way': ${msg.createdAt.difference(context.message.createdAt).inMilliseconds} ms");
}
