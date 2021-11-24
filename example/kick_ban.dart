import "package:nyxx/nyxx.dart";

// Returns user that can be banned from message. Parses mention or raw id from message
SnowflakeEntity getUserToBan(IMessage message) {
  // If mentions are not empty return first mention
  if(message.mentions.isNotEmpty) {
    return message.mentions.first.id.toSnowflakeEntity();
  }

  // Otherwise split message by spaces then take lst part and parse it to snowflake and return as Snowflake entity
  return SnowflakeEntity(message.content.split(" ").last.toSnowflake());
}

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
    // Check if message content equals "!embed"
    if (e.message.content == "!ban") {

      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message.guild != null) {
        return;
      }

      // Get user to ban
      final userToBan = getUserToBan(e.message);

      // Ban user using variable initialized before
      await e.message.guild!.getFromCache()!.ban(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }

    // Check if message content equals "!embed"
    if (e.message.content == "!ban") {
      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message.guild != null) {
        return;
      }

      // Get user to kick
      final userToBan = getUserToBan(e.message);

      // Kick user
      await e.message.guild!.getFromCache()!.kick(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }
  });
}
