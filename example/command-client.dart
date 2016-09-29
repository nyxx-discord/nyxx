import 'package:discord/discord.dart' as discord;
import 'package:discord/command.dart' as command;

void main() {
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
