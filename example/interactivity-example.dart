library test;

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

main() async {
  nyxx.Client bot = nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((e) async {
    var ch = bot.channels["422285619952222208"] as nyxx.TextChannel;

    // Create and send paginated message. After 15 minutes message will be deactivated.
    await command.Interactivity.paginate(ch, ["SIema", "Czy to dziala?", "Hope so"], timeout: const Duration(minutes: 15));

    // To create poll you need channel, title and map of emojis and Names of options.
    // Result is returned after timeout.
    var res = await command.Interactivity.createPoll(ch, "Ttul", {
      nyxx.EmojisUnicode.stopwatch: "Stopwatch",
      nyxx.EmojisUnicode.abcd: "abcd"
    }, timeout: const Duration(seconds: 10));

    print(res);
  });
}