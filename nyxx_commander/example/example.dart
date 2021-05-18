import "package:nyxx/nyxx.dart";
import "package:nyxx_commander/commander.dart";

void main() {
  // Start bot
  final bot = Nyxx("TOKEN", GatewayIntents.allUnprivileged);

  // Start commander with prefix `!`
  Commander(bot, prefix: "!")
    ..registerCommand("ping", (context, message) { // register command ping that will answer pong
      context.reply(MessageBuilder.content("Pong"));
    });
}
