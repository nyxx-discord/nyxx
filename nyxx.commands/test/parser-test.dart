import 'dart:async';
import 'dart:io';

import 'package:nyxx/Vm.dart';
import 'package:nyxx.commands/commands.dart';

void main() {
  setupDefaultLogging();

  var env = Platform.environment;
  var bot = NyxxVm(env['DISCORD_TOKEN'], ignoreExceptions: false);

  bot.onMessageReceived.listen((event) async {
    if(event.message == null) {
      return;
    }

    if(event.message!.content == "Test 1") {
      event.message!.delete();
    }

    if(event.message!.content == "Test 2") {
      event.message!.delete();
    }

    if(event.message!.content == "Test 10") {
      await event.message!.delete();

      await event.message!.channel.send(content: "CommandsParser tests completed sucessfuly!");
      exit(0);
    }
  });

  bot.onReady.listen((e) async {
    var channel = bot.channels[Snowflake('422285619952222208')] as TextChannel;

    await channel.send(content: "Testing CommandsParser");

    var msg1 = await channel.send(content: "test>test1");
    msg1.delete();

    var msg2 = await channel.send(content: "test>test2 arg1");
    msg2.delete();

    var msg3 = await channel.send(content: "test>test3");
    msg3.delete();
  });

  CommandParser("test>", bot, (message, author, channel) async {
    if(message.content.endsWith("test3")) {
      await channel.send(content: "Test 10");
      return true;
    }

    return true;
  }).bind("test1", (message, author, channel, args) async => {
      await channel.send(content: "Test 1")
  }).bind("test2", (message, author, channel, args) async => {
    if(args.length == 2 && args.last == "arg1") {
      await channel.send(content: "Test 2")
    }
  });

  Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });
}