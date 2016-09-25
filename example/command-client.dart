import 'package:discord_dart/discord.dart' as discord;
import 'package:discord_dart/command.dart' as command;

main() {
  var bot = new discord.Client("your token");
  var commands = new command.Client(bot, "!");

  bot.on('ready', (e) {
    print("Ready!");
  });

  commands.on('ping', (e) {
    var m = e.message;
    m.channel.sendMessage("Pong!");
  });
}
