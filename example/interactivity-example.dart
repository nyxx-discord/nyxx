library test;

import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/utils.dart';

import 'dart:io';

void main() async {
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((e) async {
    var ch = bot.channels[Snowflake("422285619952222208")] as TextChannel;

    // Create and send paginated message. After 15 minutes message will be deactivated.
    var pagination = Pagination.fromString(
        "Mi scias, kio estas. "
        "Ci tio estos tre longa alineo car mi bezonas multan tekston. "
        "Mi ne scias, kion skribi ci tie, sed mi esperas, ke neniu ĝin legos (au almenau kun kompreno) "
        "Sed se vi legis gin de komprenu ci tion, "
        "skribu al mi en priv, mi diros al vi ion belan. "
        "Mi ŝercis, mi ne estas bela. ",
        ch);

    await pagination.paginate(bot, timeout: const Duration(minutes: 15));

    // To create poll you need channel, title and map of emojis and Names of options.
    // Result is returned after timeout.
    var res = await createPoll(
        ch,
        "Ttul",
        {
          UnicodeEmoji(emojisUnicode['stopwatch']): "Stopwatch",
          UnicodeEmoji(emojisUnicode['abcd']): "abcd"
        },
        timeout: const Duration(seconds: 10));

    print(res);
  });
}
