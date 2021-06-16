import "dart:io";

import "package:nyxx_lavalink/lavalink.dart";
import "package:nyxx/nyxx.dart";

// This is a very simple example, for a more complete one take a look at
// https://github.com/AlvaroMS25/nyxx_lavalink_testbot

void main() async {
  final client = Nyxx(Platform.environment["DISCORD_TOKEN"]!, GatewayIntents.all);
  final cluster = Cluster(client, Snowflake("YOUR_BOT_ID"));
  final channelId = Snowflake("CHANNEL_ID_HERE");

  client.onReady.listen((event) {
    print("ready");
  });

  final options = NodeOptions(port: 2333, password: "testing");

  await cluster.addNode(options);

  await for (final msg in client.onMessageReceived) {
    if(msg.message.content == "!join") {
      final channel = await client.fetchChannel<VoiceGuildChannel>(channelId);

      channel.connect();

      cluster.getOrCreatePlayerNode(channelId);
    } else if(msg.message.content == "!queue") {
      final node = cluster.getOrCreatePlayerNode(channelId);

      final player = node.players[channelId];

      print(player!.queue);
    } else if (msg.message.content == "!skip") {
      final node = cluster.getOrCreatePlayerNode(channelId);

      node.skip(channelId);
    } else if(msg.message.content == "!nodes") {
      print("${cluster.connectedNodes.length} available nodes");
    } else if (msg.message.content == "!update") {
      final node = cluster.getOrCreatePlayerNode(channelId);

      node.updateOptions(NodeOptions(port: 18101, password: "testing"));
    } else {
      final node = cluster.getOrCreatePlayerNode(channelId);

      final searchResults = await node.searchTracks(msg.message.content);

      node.play(channelId, searchResults.tracks[0]).queue();
    }
  }
}