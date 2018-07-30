import 'package:nyxx/nyxx.dart' as nyxx;

import 'dart:io';

// Main function
void main() {
  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((nyxx.ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessage.listen((nyxx.MessageEvent e) {
    if (e.message.content == "!ping") {
      e.message.channel.send(content: "Pong!");
    }
  });
}
