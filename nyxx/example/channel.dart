import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance. Replace string with your token
  final bot = Nyxx("<TOKEN>");

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.onMessageReceived.listen((MessageReceivedEvent e) async {
    // Check if message content equals "!embed"
    if (e.message.content == "!create_channel") {
      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message is! GuildMessage) {
        return;
      }

      // Get guild object from message
      final guild = (e.message as GuildMessage).guild!;

      // Created text channel. Remember discord will lower the case of name and replace spaces with - and do other sanitization
      final channel = await guild.createChannel("TEST CHANNEL", ChannelType.text) as GuildTextChannel;

      // Send feedback
      await e.message.channel.send(content: "Crated ${channel.mention}");

      // Delete channel that we just created
      await channel.delete();

      // Send feedback
      await e.message.channel.send(content: "Deleted ${channel.mention}");
    }
  });
}
