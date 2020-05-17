import 'package:nyxx/nyxx.dart';

import 'dart:io';

// Main function
void main() {
  // Create new bot instance
  Nyxx bot = Nyxx("<TOKEN>");

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((MessageReceivedEvent e) {
    // When receive specific message send new file to channel
    if (e.message.content == "!give-me-file") {
      // Send file via `sendFile()`. File path must be in list, so we have there `[]` syntax.
      // First argument is path to file. When no additional arguments specified file is sent as is.
      // File has to be in root project directory if path is relative.
      e.message.channel.send(files: [AttachmentBuilder.path("kitten.jpeg")]);
    }

    if (e.message.content == "!give-me-embed") {
      // Files can be used within embeds as custom images
      var attachment = AttachmentBuilder.file(File("kitten.jpeg"));

      // Use `attachUrl` property in embed to link uploaded file to thumbnail in that case
      var embed = EmbedBuilder()
        ..title = "Example Title"
        ..thumbnailUrl = attachment.attachUrl;

      // Sent all together
      e.message.channel.send(files: [attachment], embed: embed, content: "HEJKA!");
    }
  });
}
