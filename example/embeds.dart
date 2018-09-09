import 'package:nyxx/nyxx.dart' as nyxx;

import 'dart:io';

// Main function
void main() {
  // Create new bot instance
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((nyxx.ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessage.listen((nyxx.MessageEvent e) {
    if (e.message.content == "!embed") {
      // Build embed with `..Builder` classes.

      // Create author section of embed.
      var author = nyxx.EmbedAuthorBuilder()
        ..name = e.message.author.username
        ..iconUrl = e.message.author.avatarURL();

      // Create embed with previously created author section.
      var embed = nyxx.EmbedBuilder()
        ..addField(name: "Example field title", content: "Example value")
        ..author = author;

      // Sent an embed
      e.message.channel.send(embed: embed);
    }
  });
}
