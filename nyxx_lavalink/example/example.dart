import "dart:io";

import "package:nyxx_lavalink/lavalink.dart";
import "package:nyxx/nyxx.dart";

void main() async {
  final client = Nyxx(Platform.environment["DISCORD_TOKEN"]!, GatewayIntents.all);
  final cluster = Cluster(client, Snowflake("YOUR_BOT_ID"));

  // This is a really simple example, so we'll define the guild and
  // the channel where the bot will play music on
  final guildId = Snowflake("GUILD_ID_HERE");
  final channelId = Snowflake("CHANNEL_ID_HERE");

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

      // skip the current track, if it's the last on the queue, the
      // player will stop automatically
      node.skip(guildId);
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
