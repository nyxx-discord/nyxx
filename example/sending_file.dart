import "dart:io";

import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot started listening to events.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) {
    // When receive specific message send new file to channel
    if (e.message.content == "!give-me-file") {
      // Files argument needs to be list of AttachmentBuilder object with
      // path to file that you want to send. You can also use other
      // AttachmentBuilder constructors to send File object or raw bytes
      e.message.channel.sendMessage(MessageBuilder()..files = [AttachmentBuilder.path("kitten.jpeg")]);
    }

    // Check if message content equals "!givemeembed"
    if (e.message.content == "!givemeembed") {
      // Files can be used within embeds as custom images
      final attachment = AttachmentBuilder.file(File("kitten.jpeg"));

      // use attachUrl getter from AttachmentBuilder class to get reference to uploaded file
      final embed = EmbedBuilder()
        ..title = "Example Title"
        ..thumbnailUrl = attachment.attachUrl;

      // Send everything we created before to channel where message was received.
      // e.message.channel.getFromCache()?.sendMessage(files: [attachment], embed: embed, content: "HEJKA!");
      e.message.channel.sendMessage(
          MessageBuilder.content("HEJKA!")
            ..embeds = [embed]
            ..files = [attachment]
      );
    }
  });
}
