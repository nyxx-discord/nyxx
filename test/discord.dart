import 'dart:io';
import 'package:discord_dart/discord.dart' as discord;

main() {
  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);

  bot.on('ready', (e) async {
    bot.sendMessage("228308788954791939", "New Travis CI build, running tests.");
    var m = await bot.sendMessage('228308788954791939', "Message test.");
    await bot.editMessage('228308788954791939', m, "Edit test.");
    await bot.deleteMessage("228308788954791939", m);
    await bot.sendMessage('228308788954791939', "Tests completed successfully!");
    exit(0);
  });
}
