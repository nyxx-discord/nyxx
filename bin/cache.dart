// import 'dart:io';

// import 'package:nyxx/src/cache/cache.dart';
// import 'package:nyxx/src/client.dart';
// import 'package:nyxx/src/intents.dart';
// import 'package:nyxx/src/models/snowflake.dart';

// void main(List<String> args) async {

//   // await Future.delayed(const Duration(seconds: 5));

//   final client = await Nyxx.connectGateway(Platform.environment['DISCORD_TOKEN']!, GatewayIntents.all);

//   // await client.commands.list().asStream().drain();

//   // await client.onGuildCreate.listen((event) async {
//   //   await client.gateway.listGuildMembers(event.guild.id).drain();
//   //   await event.guild.members.list().asStream().drain();
//   //   // await event.guild.commands.list().asStream().drain();
//   // }).asFuture();

//   await client.onReady.first;

//   final m = await client.guilds.get(const Snowflake(911736666551640075)).then((g) => g.members.get(const Snowflake(253554702858452992)));
//   print(m);
//   print(m.bannerHash);
// }
import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/builders/emoji/emoji.dart';

void main(List<String> args) async {
  final client = await Nyxx.connectRest(Platform.environment['TOKEN']!);

  final emoji = await client.emojis
      .create(ApplicationEmojiBuilder(name: 'nyxx_icon', image: ImageBuilder.png(await File('nyxx-logo-cropped-c.png').readAsBytes())));

  print(emoji);
  print(await client.application.emojis.list());
  await client.close();
}
