import "package:nyxx/nyxx.dart";

DiscordColor getColorForUserFromMessage(IMessage message) {
  if (message.guild != null) {
    return PermissionsUtils.getMemberHighestRole(message.member!).color;
  }

  return DiscordColor.black;
}

// Main function
void main() async {
  // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged | GatewayIntents.messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()); // Plugin that handles uncaught exceptions that may occur

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    // Check if message content equals "!embed"
    if (e.message.content == "!embed") {

      // Create embed with author and footer section.
      final embed = EmbedBuilder()
        ..addField(name: "Example field title", content: "Example value")
        ..addField(builder: (field) {
          field.content = "Hi";
          field.name = "Example Field";
        })
        ..addAuthor((author) {
          author.name = e.message.author.username;
          author.iconUrl = e.message.author.avatarUrl();
        })
        ..addFooter((footer) {
          footer.text = "Footer example, good";
        })
        ..color = getColorForUserFromMessage(e.message);

      // Sent an embed to channel where message received was sent
      await e.message.channel.sendMessage(MessageBuilder.embed(embed));
    }
  });

  await bot.connect();
}
