import 'dart:async';
import 'package:nyxx/nyxx.dart';

/// Runs specific code on every target periodically.
///
/// ```
/// // Create new scheduler and fill out all required fields
///  var scheduler = Scheduler(bot)
///    ..runEvery = const Duration(seconds: 1)
///    ..targets = [Snowflake(422285619952222208)]
///    ..action = (channel) {
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

  /// Reference to client instance
  Nyxx _client;

  Scheduler(this._client, [this.runEvery, this.action, this.targets]);

  /// Starts scheduler
  Future<void> start() async {
    _client.onReady.listen((e) {
      List<MessageChannel> _targets = List();
      targets
          .forEach((s) => _targets.add(_client.channels[s] as MessageChannel));

      _targets.forEach((chan) => action(chan, null));

      this._t = Timer.periodic(
          runEvery, (Timer t) => _targets.forEach((chan) => action(chan, t)));
    });
  }

  /// Stops scheduler
  void stop() => _t.cancel();
}
