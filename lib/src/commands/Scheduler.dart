part of nyxx.commands;

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
///  /// Run schduler
///  await scheduler.run();
/// ```
class Scheduler {
  /// Action will be run every [runEvery] amount of time.
  Duration _runEvery;
  set runEvery(Duration duration) {
    if (duration.inMinutes < 1)
      throw Exception("Scheduler cannot send message under 1/minute");

    _runEvery = _runEvery;
  }

  /// Funtion to run on every targeted channel
  void Function(MessageChannel channel) func;

  /// List of targeted channel
  List<Snowflake> targets;

  Client _client;
  Timer _t;

  Scheduler(this._client);

  /// Starts scheduler
  Future<Null> run() async {
    _client.onReady.listen((e) {
      List<MessageChannel> _targets;
      targets
          .forEach((s) => _targets.add(_client.channels[s] as MessageChannel));

      this._t = Timer.periodic(_runEvery, (Timer t) {
        for (var target in _targets) {
          func(target);
        }
      });
    });

    return null;
  }

  /// Stops scheduler
  void stop() => _t.cancel();
}
