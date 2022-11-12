import "package:nyxx/nyxx.dart";

// Returns user that can be banned from message. Parses mention or raw id from message
SnowflakeEntity getUserToKickOrBan(IMessage message) {
  // If mentions are not empty return first mention
  if (message.mentions.isNotEmpty) {
    return message.mentions.first.id.toSnowflakeEntity();
  }

  // Otherwise split message by spaces then take last part and parse it to snowflake and return as Snowflake entity
  return SnowflakeEntity(message.content.split(" ").last.toSnowflake());
}

// Main function
void main() {
  // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged | GatewayIntents.messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    // Check if message content equals "!ban"
    if (e.message.content == "!ban") {

      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if (e.message.guild != null) {
        return;
      }

      // Get user to ban
      final userToBan = getUserToKickOrBan(e.message);

      // Ban user using variable initialized before
      await e.message.guild!.getFromCache()!.ban(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }

    // Check if message content equals "!kick"
    if (e.message.content == "!kick") {
      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if (e.message.guild != null) {
        return;
      }

      // Get user to kick
      final userToBan = getUserToKickOrBan(e.message);

      // Kick user
      await e.message.guild!.getFromCache()!.kick(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }
  });
}
