import 'package:discord/discord.dart' as discord;
import 'package:discord/vm.dart' as discord;

void main() {
  discord.configureDiscordForVM();
  discord.Client bot = new discord.Client("your token");

  bot.onReady.listen((discord.ReadyEvent e) {
    print("Ready!");
  });

  bot.onMessage.listen((discord.MessageEvent e) {
    if (e.message.content == "!ping") {
      e.message.channel.sendMessage(content: "Pong!");
    }
  });
}