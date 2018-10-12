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
  bot.onMessageReceived.listen((nyxx.MessageReceivedEvent e) {
    if (e.message.content == "!embed") {
      // Build embed with `..Builder` classes.

      // Create embed with author and footer section.
      var embed = nyxx.EmbedBuilder()
        ..addField(name: "Example field title", content: "Example value")
        ..addField(builder: (field) {
          field.content = "Hi";
          field.name = "Example Filed";
        })
        ..addAuthor((author) {
          author.name = e.message.author.username;
          author.iconUrl = e.message.author.avatarURL();
        })
        ..addFooter((footer) {
          footer.text = "Footer example, good";
        })
        ..color = (e.message.author as nyxx.Member).color;

      // Sent an embed
      e.message.channel.send(embed: embed);
    }
  });
}
