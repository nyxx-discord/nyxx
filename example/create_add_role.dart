import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged);

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    // Check if message content equals "!embed"
    if (e.message.content == "!role") {

      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message.guild != null) {
        return;
      }

      // Creating role with RoleBuilder. We have to cast `e.message` to GuildMessage because we want to access guild property
      // and generic dont have that.
      final role = await e.message.guild!.getFromCache()!.createRole(RoleBuilder("testRole")..color = DiscordColor.chartreuse);

      // Cast message author to member because webhook can also be message author. And add role to user
      await e.message.member!.addRole(role);

      // Send message with confirmation of given action
      await e.message.channel.sendMessage(MessageBuilder.content("Added [${role.name}] to user: [${e.message.author.tag}"));
    }
  });
}
