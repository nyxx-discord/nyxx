import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as cmd;

import 'dart:io';
import 'dart:async';

void main() {
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Manual banchmark
  bot.onMessage.listen((nyxx.MessageEvent e) async{
    if (e.message.content == "!bm") {
      var msg = await e.message.channel.send(content: "Pong!");
      await msg.edit(content: "Total response time in 'manual way': ${msg.createdAt.difference(e.message.createdAt).inMilliseconds} ms");
    }
  });

  new cmd.CommandsFramework("!", bot)
    ..registerLibraryCommands();
}

@cmd.Command(name: "bc")
class Bench extends cmd.CommandContext {
  @cmd.Command(main: true)
  Future<void> benchmark() async {
    var msg = await reply(content: "Pong!");
    await msg.edit(content: "Total response time in 'command way': ${msg.createdAt.difference(message.createdAt).inMilliseconds} ms");
  }
}
