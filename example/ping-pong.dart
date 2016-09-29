import 'package:discord/discord.dart' as discord;

void main() {
  var bot = new discord.Client("your token");

  bot.on('ready', (e) {
    print("Ready!");
  });

  bot.on('message', (e) {
    var m = e.message;

    if (m.content == "!ping") {
      m.channel.sendMessage("Pong!");
    }
  });
}
