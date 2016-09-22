import 'dart:io';
import 'package:discord_dart/discord.dart' as discord;

main() {
  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);
  const duration = const Duration(seconds: 1);

  bot.on('ready', (e) async {
    bot.sendMessage("228308788954791939", "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    var m = await bot.sendMessage('228308788954791939', "Message test.");
    await bot.editMessage('228308788954791939', m, "Edit test.");
    await bot.deleteMessage("228308788954791939", m);
    await bot.sendMessage("228308788954791939", "--trigger-test");
  });
  
  bot.on('message', (e) async {
    var m = e.message;
    
    if (m.channel.id == "228308788954791939" && m.author.id == bot.user.id && m.content == "--trigger-test") {
      await bot.deleteMessage(m.channel, m);
      await bot.sendMessage(m.channel, "Tests completed successfully!");
      print("Discord tests completed successfully!");
      exit(0);
    }
  });
}
