import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/setup.wm.dart' as setup;

import 'dart:io';

// Main function
void main() {
  // Setup bot for VM
  setup.configureDiscordForVM();

  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((nyxx.ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessage.listen((nyxx.MessageEvent e) {
    if (e.message.content == "!embed") {
      // Build embed with `..Builder` classes.

      // Create author section of embed.
      var author = new nyxx.EmbedAuthorBuilder()
        ..name = e.message.author.username
        ..iconUrl = e.message.author.avatarURL();

      // Create embed with previously created author section.
      // Only field which is required to create is `title`.
      var embed = new nyxx.EmbedBuilder("Example Title")
        ..addField(name: "Example field title", value: "Example value")
        ..author = author;

      // Sent an embed
      e.message.channel.send(embed: embed);
    }
  });
}
