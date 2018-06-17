import 'package:nyxx/discord.dart' as discord;
import 'package:nyxx/vm.dart' as discord;

import 'dart:async';
import 'dart:io';

void main() {
  discord.configureDiscordForVM();
  discord.Client bot =
      new discord.Client(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((discord.ReadyEvent e) {
    print("Ready!");
  });

  bot.onMessage.listen((discord.MessageEvent e) {
    if (e.message.content == "!ping") {
      e.message.channel.sendMessage(content: "Pong!");
    }
  });
}
