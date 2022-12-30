import "package:nyxx/nyxx.dart";

// Main function
void main() async {
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
    // Check if message content equals "!embed"
    if (e.message.content == "!create_channel") {
      // Make sure that the message was sent in a guild and not in a dm, because we can only create channels in guilds
      if (e.message.guild == null) {
        return;
      }

      // Get guild object from message
      final guild = e.message.guild.getFromCache()!;

      // Created text channel. Remember discord will lower the case of name and replace spaces with - and do other sanitization
      final channel = await guild.createChannel(TextChannelBuilder.create("Test channel")) as ITextGuildChannel;

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("Crated ${channel.mention}"));

      // Delete channel that we just created
      await channel.delete();

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("Deleted ${channel.mention}"));
    }
  });
}
