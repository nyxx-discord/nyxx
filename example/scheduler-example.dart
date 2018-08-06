import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

void main() async {
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  /// Create new scheduler and fill out all required fields
  var scheduler = new command.Scheduler(bot)
    ..runEvery = const Duration(seconds: 1)
    ..targets = [const nyxx.Snowflake.static("422285619952222208")]
    ..func = (channel) {
      channel.send(content: "test");
    };

  /// Disable scheduler after 5 seconds
  new Timer(const Duration(seconds: 5), () => scheduler.stop());

  /// Run schduler
  await scheduler.run();
}
