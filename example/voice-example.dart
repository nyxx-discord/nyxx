import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/lavalink.dart' as voice;

import 'dart:io';

// Main function
void main() {
  configureNyxxForVM();

  // Create new bot instance
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((nyxx.ReadyEvent e) {
    // Init voice service with client id, Client instance and absolute path to lavalink config.
    voice.init("127.0.0.1:3454", "127.0.0.1:4535", "PASS");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((nyxx.MessageReceivedEvent e) async {
    if (e.message.content == "!play") {
      // Get player for guild.
      var player = await voice.getPlayer(e.message.guild);

      // Get first voice channel
      var channel = e.message.guild.channels.values
          .firstWhere((ch) => ch is nyxx.VoiceChannel) as nyxx.VoiceChannel;

      // Connect to channel
      await player.connect(channel);

      // Resolve url to Lavalink track
      // Read here: https://github.com/Frederikam/Lavalink
      var track = await player.resolve("oMRZp7cp79g");

      // Play track
      await player.play(track.entity as voice.Track);
    } else if (e.message.content == "!stop") {
      // Always stops music and disconnects from channel
      // Player instance is cached, so invoking this method has no cost
      var player = await voice.getPlayer(e.message.guild);

      // Disconnect player
      await player.disconnect();

      // If you know that you wont use voice service anymore - destroy player.
      await voice.destroyPlayer(player);
    }
  });
}
