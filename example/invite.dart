import "package:nyxx/nyxx.dart";

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
    // Check if message content equals "!create_channel"
    if (e.message.content == "!create_channel") {
      // Make sure that the message was sent in a guild and not in a dm, because we cant make invites in dms
      if (e.message.guild == null) {
        return;
      }

      // Create default invite. We have to cast channel to access guild specific functionality.
      final invite = await (e.message.channel as ITextGuildChannel).createInvite();

      // Send back invite url
      await e.message.channel.sendMessage(MessageBuilder.content(invite.url));
    }
  });
}
