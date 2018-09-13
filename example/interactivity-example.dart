library test;

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/utils.dart' as utils;

import 'dart:io';

void main() async {
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((e) async {
    var ch = bot.channels["422285619952222208"] as nyxx.TextChannel;

    // Create and send paginated message. After 15 minutes message will be deactivated.
    var pagination = command.Pagination.fromString(
        "Mi scias, kio estas. "
        "Ci tio estos tre longa alineo car mi bezonas multan tekston. "
        "Mi ne scias, kion skribi ci tie, sed mi esperas, ke neniu ĝin legos (au almenau kun kompreno) "
        "Sed se vi legis gin de komprenu ci tion, "
        "skribu al mi en priv, mi diros al vi ion belan. "
        "Mi ŝercis, mi ne estas bela. ",
        ch);

    await pagination.paginate(timeout: const Duration(minutes: 15));

    // To create poll you need channel, title and map of emojis and Names of options.
    // Result is returned after timeout.
    var res = await command.createPoll(
        ch,
        "Ttul",
        {
          nyxx.UnicodeEmoji(utils.emojisUnicode['stopwatch']): "Stopwatch",
          nyxx.UnicodeEmoji(utils.emojisUnicode['abcd']): "abcd"
        },
        timeout: const Duration(seconds: 10));

    print(res);
  });
}
