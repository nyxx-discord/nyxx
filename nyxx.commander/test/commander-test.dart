import 'dart:async';
import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx.commander/commander.dart';

void main() {
  setupDefaultLogging();

  var bot = Nyxx(Platform.environment['DISCORD_TOKEN'], ignoreExceptions: false);

  bot.onMessageReceived.listen((event) async {
    if(event.message.content == "Test 1") {
      event.message.delete();
    }

    if(event.message.content == "Test 2") {
      event.message.delete();
    }

    if(event.message.content == "Test 10") {
      await event.message.delete();

      await event.message.channel.send(content: "Commander tests completed sucessfuly!");
      exit(0);
    }
  });

  bot.onReady.listen((e) async {
    var channel = bot.channels[Snowflake('422285619952222208')] as TextChannel;

    await channel.send(content: "Testing Commander");

    var msg1 = await channel.send(content: "test>test1");
    msg1.delete();

    var msg2 = await channel.send(content: "test>test2 arg1");
    msg2.delete();

    var msg3 = await channel.send(content: "test>test3");
    msg3.delete();
  });

  Commander(bot, prefix: "test>", beforeCommandHandler: (context, message)  async{
    if(message.endsWith("test3")) {
      await context.channel.send(content: "Test 10");
      return true;
    }

    return true;
  })..registerCommand("test1", (context, message) async {
    await context.channel.send(content: "Test 1");
  })..registerCommand("test2", (context, message) async {
    var args = message.split(" ");

    if(args.length == 2 && args.last == "arg1") {
      await context.channel.send(content: "Test 2");
    }
  })..registerCommand("test3", (context, message) async {
    await context.message.delete();
  });

  Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });
}