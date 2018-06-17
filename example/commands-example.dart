import 'package:discord/discord.dart' as discord;
import 'package:discord/vm.dart' as discord;

void main() {
  discord.configureDiscordForVM();
  discord.Client bot = new discord.Client("TOKEN");

  var commands = new discord.Commands('!');
  commands.add(new PongCommand());
  commands.add(new EchoCommand());

  bot.onMessage.listen((discord.MessageEvent e) {
    commands.dispatch(e);
  });

  bot.onReady.listen((discord.ReadyEvent e) {
    print("Ready!");
  });
}

class PongCommand extends discord.Command {
  PongCommand() : super("ping", "Checks if bot is connected!", "!ping");

  override run(Message message) {
    message.channel.sendMessage(content: "Pong!");
  }
}

class EchoCommand extends discord.Command {
  EchoCommand() : super("echo", "Echoes bot message!", "!echo <message>");

  override run(Message message) {
    message.channel.sendMessage(content: message.content);
  }
}
