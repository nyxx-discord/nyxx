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
    if (e.message.content == "!addReadPerms") {

      // Dont process message when not send in guild context
      if(e.message is! GuildMessage) {
        return;
      }

      // Get current channel
      final messageChannel = e.message.channel as CacheGuildChannel;

      // Get member from id
      final member = await (e.message as GuildMessage).guild!.getMemberById(302359032612651009.toSnowflake());

      // Get current member permissions in context of channel
      final permissions = messageChannel.effectivePermissions(member);

      // Create new channel permission override
      await messageChannel.editChannelPermission(PermissionsBuilder()..sendMessages = true, member);
    }
  });
}
