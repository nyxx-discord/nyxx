import 'dart:io';

import 'package:nyxx.commander/commander.dart';
import 'package:nyxx/Vm.dart';

void main() {
  setupDefaultLogging();
  final bot = NyxxVm(Platform.environment['DISCORD_TOKEN'], ignoreExceptions: true);
  final commander = Commander(bot, prefix: "s!!!")
    ..registerCommand("test", (context, message) async {
      context.channel.send(content: "TEST!");
    });
}