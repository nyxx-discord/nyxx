import 'dart:io';
import 'package:discord_dart/discord.dart' as discord;

main() {
  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);
  const duration = const Duration(seconds: 1);

  bot.on('ready', (e) async {
    bot.sendMessage("228308788954791939", "New Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    var m = await bot.sendMessage('228308788954791939', "Message test.");
    sleep(duration);
    await bot.editMessage('228308788954791939', m, "Edit test.");
    sleep(duration);
    await bot.deleteMessage("228308788954791939", m);

    await bot.sendMessage('228308788954791939', "Tests completed successfully!");
    exit(0);
  });
}
