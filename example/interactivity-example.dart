library test;

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';

void main() async {
  nyxx.Client bot = nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((e) async {
    var ch = bot.channels["422285619952222208"] as nyxx.TextChannel;

    // Create and send paginated message. After 15 minutes message will be deactivated.
    var pagination = new command.Pagination.fromString(
        "Siema siema co tam. "
        "To bedzie bardzo dlugi paragraf poniewaz potrzebuje duzo tesktu. "
        "Nie wiem co tu napisac ale mam nadzieje ze nikt tego nie przeczyta "
        "(a przynajmniej ze zrozumieniem). Jesli jednak przeczytasz to ze "
        "zrozumieniem to napisz do mnie na priv to powiem ci cos milego. "
        "Nie no zartowalem ja nie jestem mily.",
        ch);

    await pagination.paginate(timeout: const Duration(minutes: 15));

    // To create poll you need channel, title and map of emojis and Names of options.
    // Result is returned after timeout.
    var res = await command.createPoll(
        ch,
        "Ttul",
        {
          nyxx.EmojisUnicode.stopwatch: "Stopwatch",
          nyxx.EmojisUnicode.abcd: "abcd"
        },
        timeout: const Duration(seconds: 10));

    print(res);
  });
}
