import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/utils.dart' as util;

import 'dart:io';
import 'dart:async';

void main() async {
  configureNyxxForVM();
  var bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  /// Create new scheduler and fill out all required fields
  var scheduler = util.Scheduler(bot)
    ..runEvery = const Duration(seconds: 2)
    ..targets = [nyxx.Snowflake("422285619952222208")]
    ..action = (channel, t) {
      channel.send(content: "test");
    };

  /// Disable scheduler after 5 seconds
  Timer(const Duration(seconds: 10), () => scheduler.stop());

  /// Run scheduler
  await scheduler.start();
}
