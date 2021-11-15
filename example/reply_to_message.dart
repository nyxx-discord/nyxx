import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged)
    ..connect();

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    // Check if message content equals "!reply"
    if (e.message.content == "!reply") {
      // Create message with some content and then add to builder
      // additional ReplyBuilder that is created from message we received in event
      final replyBuilder = ReplyBuilder.fromMessage(e.message);
      final messageBuilder = MessageBuilder.content("This is how replies work")
        ..replyBuilder = replyBuilder;

      // If you dont want to mention user that invoked that command user AllowedMentions
      final allowedMentionsBuilder = AllowedMentions()
        ..allow(reply: false);

      messageBuilder.allowedMentions = allowedMentionsBuilder;

      await e.message.channel.sendMessage(messageBuilder);
    }
  });
}
