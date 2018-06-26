import 'dart:io';
import 'dart:async';

import 'package:nyxx/discord.dart' as discord;
import 'package:nyxx/vm.dart' as discord;

class TestCommand extends discord.Command {
  TestCommand() : super("test", "Checks if everything is running", "!test");

  @override
  run(discord.Message message) async {
    await message.channel.sendMessage(content: "\~~test is working correctly");
  }
}

void main() {
  discord.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);

  var commandsListener = new discord.Commands('~~', bot)
    ..add(new TestCommand())
    ..commandNotFoundEvent.listen((m) {
      m.channel.sendMessage(content: "Command '${m.content}' not found!");
    })
    ..ignoreBots = false;

  new Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  bot.onReady.listen((e) async {
    var channel = bot.channels['422285619952222208'];
    channel.sendMessage(
        content:
            "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    var m = await channel.sendMessage(content: "Message test.");
    await m.edit(content: "Edit test.");
    await m.delete();
    await channel.sendMessage(content: "--trigger-test");

    var mm = await channel.sendMessage(content: "~~test");
    await mm.delete();

    var mmm = await channel.sendMessage(content: "~~notFound");
    await mmm.delete();
  });

  bot.onMessage.listen((e) async {
    var m = e.message;

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "--trigger-test") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "\~~test is working correctly") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "Command '~~notFound' not found!") {
      await m.delete();
      await m.channel.sendMessage(content: "Tests completed successfully!");
      print("Nyxx tests completed successfully!");
      await bot.destroy();
      exit(0);
    }
  });
}
