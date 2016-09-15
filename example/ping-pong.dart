import 'package:DiscordDart/discord_dart.dart' as discord;

main() {
  var bot = new discord.Client("your token");

  bot.onEvent('ready', () {
    print("Ready!");
  });

  bot.onEvent('message', (m) async {
    if (m.content == "!ping") {
      bot.sendMessage(m.channel, "");
    }
  });
}
