import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/utils.dart';

import 'dart:io';
import 'dart:async';

void main() async {
  configureNyxxForVM();
  var bot = Nyxx(Platform.environment['DISCORD_TOKEN']);

  /// Create new scheduler and fill out all required fields
  var scheduler = Scheduler(bot)
    ..runEvery = const Duration(minutes: 15)
    ..targets = [Snowflake("422285619952222208")]
    ..action = (channel, t) {
      channel.send(
          content:
              "This is example usage of Scheduler. Don't use it to abuse API tho");
    };

  /// Disable scheduler after 5 seconds
  Timer(const Duration(seconds: 10), () => scheduler.stop());

  /// Run scheduler
  await scheduler.start();
}
