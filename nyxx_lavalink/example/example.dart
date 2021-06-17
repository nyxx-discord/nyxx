import "dart:io";

import "package:nyxx_lavalink/lavalink.dart";
import "package:nyxx/nyxx.dart";

// This is a very simple example, for a more complete one take a look at
// https://github.com/AlvaroMS25/nyxx_lavalink_testbot

void main() async {
  final client = Nyxx(Platform.environment["DISCORD_TOKEN"]!, GatewayIntents.all);
  final cluster = Cluster(client, Snowflake("YOUR_BOT_ID"));
  final channelId = Snowflake("CHANNEL_ID_HERE");
  final guildId = Snowflake("GUILD_ID_HERE");

  // Add your lavalink nodes
  await cluster.addNode(NodeOptions());

  await for (final msg in client.onMessageReceived) {
    if(msg.message.content == "!join") {
      final channel = await client.fetchChannel<VoiceGuildChannel>(channelId);

      channel.connect();

      cluster.getOrCreatePlayerNode(guildId);
    } else if(msg.message.content == "!queue") {
      final node = cluster.getOrCreatePlayerNode(guildId);

      final player = node.players[guildId];

      print(player!.queue);
    } else if (msg.message.content == "!skip") {
      final node = cluster.getOrCreatePlayerNode(guildId);

      node.skip(channelId);
    } else if(msg.message.content == "!nodes") {
      print("${cluster.connectedNodes.length} available nodes");
    } else if (msg.message.content == "!update") {
      final node = cluster.getOrCreatePlayerNode(guildId);

      node.updateOptions(NodeOptions());
    } else {
      final node = cluster.getOrCreatePlayerNode(guildId);

      final searchResults = await node.searchTracks(msg.message.content);

      node.play(guildId, searchResults.tracks[0]).queue();
    }
  }
}
