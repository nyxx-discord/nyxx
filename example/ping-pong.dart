import 'package:discord_dart/discord.dart' as discord;

main() {
  var bot = new discord.Client("your token");

  bot.on('ready', (e) {
    print("Ready!");
  });

  bot.on('message', (e) {
    var m = e.message;

    if (m.content == "!ping") {
      bot.sendMessage(m.channel, "Pong!");
    }
  });
}
