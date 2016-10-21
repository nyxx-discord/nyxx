import 'dart:async';
import 'dart:io';

import 'package:discord/discord.dart' as discord;
import 'package:discord/discord_vm.dart' as discord;

void main() {
  discord.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);

  new Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  bot.onReady.listen((e) async {
    var channel = bot.channels['228308788954791939'];
    channel.sendMessage(
        "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    var m = await channel.sendMessage("Message test.");
    await m.edit("Edit test.");
    await m.delete();
    await channel.sendMessage("--trigger-test");
  });

  bot.onMessage.listen((e) async {
    var m = e.message;

    if (m.channel.id == "228308788954791939" &&
        m.author.id == bot.user.id &&
        m.content == "--trigger-test") {
      await m.delete();
      await m.channel.sendMessage("Tests completed successfully!");
      print("Discord tests completed successfully!");
      exit(0);
    }
  });
}
