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
    if (e.message.content == "!role") {
      // Make sure that the message was sent in a guild and not in a dm, because we cant add roles in dms
      if (e.message.guild == null) {
        return;
      }

      // Creating a role with RoleBuilder with a given color.
      final role = await e.message.guild!.getFromCache()!.createRole(RoleBuilder("testRole")..color = DiscordColor.chartreuse);

      // Add role to member.
      await e.message.member!.addRole(role);

      // Send message with confirmation of given action
      await e.message.channel.sendMessage(MessageBuilder.content("Added [${role.name}] to user: [${e.message.author.tag}"));
    }
  });
}
