import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/voice.dart' as voice;

import 'dart:io';

// Main function
void main() {
  // Create new bot instance
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((nyxx.ReadyEvent e) {
    // Init voice service with client id, Client instance and abolute path to lavalink config.
    voice.init("361949050016235520", bot, "/tmp/lavalink/application.yml");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessage.listen((nyxx.MessageEvent e) async {
    if (e.message.content == "!play") {
      // Get player for guild.
      var player = await voice.getPlayer(e.message.guild);

      // Get first voice channel
      var channel = e.message.guild.channels.values
          .firstWhere((ch) => ch is nyxx.VoiceChannel) as nyxx.VoiceChannel;

      // Resolve url to Lavalink track
      // Read here: https://github.com/Frederikam/Lavalink
      var track = await player.resolve("oMRZp7cp79g");

      // Play track
      await player.play(track.entity as voice.Track);
    } else if (e.message.content == "!stop") {
      // Always stop music and disconned
      // Player instance is cached, so invoking this method has no cost
      var player = await voice.getPlayer(e.message.guild);

      // Disconnect player
      await player.disconnect();

      // If you know that you wont use voice service anymore - destroy player.
      await voice.destroyPlayer(player);
    }
  });
}
