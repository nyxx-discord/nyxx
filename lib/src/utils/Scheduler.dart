import 'dart:async';
import 'package:nyxx/nyxx.dart';

/// Runs specific code on every target periodically.
///
/// ```
/// // Create new scheduler and fill out all required fields
///  var scheduler = command.Scheduler(bot)
///    ..runEvery = const Duration(seconds: 1)
///    ..targets = [const nyxx.Snowflake.static("422285619952222208")]
///    ..func = (channel) {
///      channel.send(content: "test");
///  };
///
///  /// Disable scheduler after 5 seconds
///  Timer(const Duration(seconds: 5), () => scheduler.stop());
///
///  /// Run scheduler
///  await scheduler.run();
/// ```
class Scheduler {
  /// Action will be run every [runEvery] amount of time.
  Duration runEvery;

  /// Function to run on every targeted channel
  void Function(MessageChannel, Timer) action;

  /// List of targeted channel
  List<Snowflake> targets;

  Timer _t;

  Nyxx client;

  Scheduler(this.client, [this.runEvery, this.action, this.targets]);

  /// Starts scheduler
  Future<Null> run() async {
    client.onReady.listen((e) {
      List<MessageChannel> _targets;
      targets
          .forEach((s) => _targets.add(client.channels[s] as MessageChannel));

      this._t = Timer.periodic(
          runEvery, (Timer t) => _targets.forEach((chan) => action));
    });

    return null;
  }

  /// Stops scheduler
  void stop() => _t.cancel();
}
