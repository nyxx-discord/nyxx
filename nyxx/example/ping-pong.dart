import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged);

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((e) {
    // Check if message content equals "!ping"
    if (e.message.content == "!ping") {
      // Send "Pong!" to channel where message was received
      e.message.channel.sendMessage(MessageBuilder.content("Pong!"));
    }
  });
}
