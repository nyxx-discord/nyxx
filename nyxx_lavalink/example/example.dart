import "dart:io";

import "package:nyxx_lavalink/lavalink.dart";
import "package:nyxx/nyxx.dart";

void main() async {
  final client = Nyxx(Platform.environment["DISCORD_TOKEN"]!, GatewayIntents.all);
  final cluster = Cluster(client, 728671963811414019.toSnowflake());

  client.onReady.listen((event) {
    print("ready");
  });

  final options = NodeOptions(port: 18100, password: "testing");

  await cluster.addNode(options);
  await cluster.addNode(NodeOptions(port: 18101, password: "testing"));

  await for (final msg in client.onMessageReceived) {
    if(msg.message.content == "!join") {
      final channel = await client.fetchChannel<VoiceGuildChannel>(769699425089748992.toSnowflake());

      channel.connect();

      cluster.getOrCreatePlayerNode(Snowflake(769699424170541067));
    } else if(msg.message.content == "!queue") {
      final node = cluster.getOrCreatePlayerNode(Snowflake(769699424170541067));

      final player = node.players[Snowflake(769699424170541067)];

      print(player!.queue);
    } else if (msg.message.content == "!skip") {
      final node = cluster.getOrCreatePlayerNode(Snowflake(769699424170541067));

      await node.skip(Snowflake(769699424170541067));
    } else if(msg.message.content == "!nodes") {
      print("${cluster.nodes} available nodes");
    } else {
      final node = cluster.getOrCreatePlayerNode(Snowflake(769699424170541067));

      final searchResults = await node.searchTracks(msg.message.content);

      final params = node.play(Snowflake(769699424170541067), searchResults.tracks[0]);

      await params.queue();
    }
  }
}