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
  //await cluster.addNode(NodeOptions(port: 18100, password: "testings"));

  await for (final msg in client.onMessageReceived) {
    print(msg);
  }
}