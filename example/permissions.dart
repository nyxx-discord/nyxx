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
    if (e.message.content == "!addReadPerms") {

      // Dont process message when not send in guild context
      if(e.message.guild != null) {
        return;
      }

      // Get current channel
      final messageChannel = e.message.channel.getFromCache() as IGuildChannel;

      // Get member from id
      final member = e.message.guild!.getFromCache()!.members[302359032612651009.toSnowflake()]!;

      // Get current member permissions in context of channel
      final permissions = await messageChannel.effectivePermissions(member);

      // Get current member permissions as builder
      final permissionsAsBuilder = permissions.toBuilder()..sendMessages = true;

      // Get first channel override as builder and edit sendMessages property to allow sending messages for entities included in this override
      final channelOverridesAsBuilder = messageChannel.permissionOverrides.first.toBuilder()..sendMessages = true;

      // Create new channel permission override
      await messageChannel.editChannelPermissions(PermissionsBuilder()..sendMessages = true, member);
    }
  });
}
