import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/setup.dart' as setup;

import 'dart:io';

void main() {
  setup.configureDiscordForVM();
  nyxx.Client bot =
      new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((nyxx.ReadyEvent e) {
    print("Ready!");
  });

  bot.onMessage.listen((nyxx.MessageEvent e) {
    if (e.message.content == "!ping") {
      e.message.channel.sendMessage(content: "Pong!");
    }
  });
}
