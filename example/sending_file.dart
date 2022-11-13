import "dart:io";

import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged | GatewayIntents.messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot started listening to events.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  late IMessage message;

  // Listen to all incoming messages via Dart Stream
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    // When receive specific message send new file to channel
    if (e.message.content == "!give-me-file") {
      // Files argument needs to be list of AttachmentBuilder object with
      // path to file that you want to send. You can also use other
      // AttachmentBuilder constructors to send File object or raw bytes
      message = await e.message.channel.sendMessage(MessageBuilder()..files = [AttachmentBuilder.path("test-image.png")]);
    }

    // You can remove attachment from message by converting `IAttachment` instance to `AttachmentMetaDataBuilder` via `toBuilder` method.
    // Also new file can be added to message by adding new file to files property of message builder
    // Remember that files can be received out of order.
    if (e.message.content == "!edit-with-more-files") {
      message.edit(
          MessageBuilder.content("Remove first file and add one more")
            ..attachments = [message.attachments.first.toBuilder()]
            ..files = [AttachmentBuilder.path('test-image2.png')]
      );
    }

    // Check if message content equals "!givemeembed"
    if (e.message.content == "!givemeembed") {
      // Files can be used within embeds as custom images
      final attachment = AttachmentBuilder.file(File("test-image.jpg"));

      // use attachUrl getter from AttachmentBuilder class to get reference to uploaded file
      final embed = EmbedBuilder()
        ..title = "Example Title"
        ..thumbnailUrl = attachment.attachUrl;

      // Send everything we created before to channel where message was received.
      e.message.channel.sendMessage(
          MessageBuilder.content("HEJKA!")
            ..embeds = [embed]
            ..files = [attachment]
      );
    }
  });
}
