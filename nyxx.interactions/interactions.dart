import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

void main() {
  final bot = Nyxx("<%TOKEN%>", GatewayIntents.all);
  final interactions = Interactions(bot);

  interactions
    ..registerHandler("test", "This is test comamnd", [], handler: (event) async {
      // Acknowledge about event so you can send reply later. You have 3 second to either ack command
      // or send response
      await event.acknowledge(showSource: true);

      // After long running task, send response
      await event.reply(content: "This is example message result");
    });
}
