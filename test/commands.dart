import 'dart:io';
import 'dart:async';

import 'package:nyxx/discord.dart' as discord;
import 'package:nyxx/vm.dart' as discord;

class TestCommand extends discord.Command {
  TestCommand() : super("test", "Checks if everything is running", "!test");

  @override
  run(discord.Message message) async {
    await message.channel.sendMessage(content: "~~test is working correctly");
  }
}

void main() {
  discord.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);

  new Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  var commandsListener = new discord.Commands('~~', bot)
    ..add(new TestCommand())
    ..ignoreBots = false;

  bot.onReady.listen((e) async {
    var channel = bot.channels['422285619952222208'];
    channel.sendMessage(
        content:
            "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}` for CommandFramework");

    var m = await channel.sendMessage(content: "~~test");
    await m.delete();
  });

  bot.onMessage.listen((e) async {
    var m = e.message;

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "~~test is working correctly") {
      await m.delete();
      await m.channel.sendMessage(
          content: "Nyxx CommandFramework test completed successfully!");
      print("Nyxx CommandFramework test completed successfully!");
      await bot.destroy();
      exit(0);
    }
  });
}
