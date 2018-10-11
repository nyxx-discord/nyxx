import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/utils.dart' as util;

import 'dart:io';
import 'dart:async';

void main() async {
  nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  /// Create new scheduler and fill out all required fields
  var scheduler = util.Scheduler()
    ..runEvery = const Duration(seconds: 1)
    ..targets = [nyxx.Snowflake("422285619952222208")]
    ..action = (channel, t) {
      channel.send(content: "test");
    };

  /// Disable scheduler after 5 seconds
  Timer(const Duration(seconds: 5), () => scheduler.stop());

  /// Run scheduler
  await scheduler.run();
}
