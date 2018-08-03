part of nyxx.commands;

/// Runs specific code on every target periodically
class Scheduler {
  /// Action will be run every [runEvery] amount of time.
  Duration runEvery;

  /// Funtion to run on every targeted channel
  void Function(MessageChannel channel) func;

  /// List of targeted channel
  List<String> targets;

  List<MessageChannel> _targets;
  Client _client;
  Timer _t;

  Scheduler(this._client) {
    _targets = new List();
  }

  Future<Null> run() async {
    _client.onReady.listen((e) {
      targets
          .forEach((s) => _targets.add(_client.channels[s] as MessageChannel));

      this._t = new Timer.periodic(runEvery, (Timer t) {
        for (var target in _targets) {
          func(target);
        }
      });
    });
  }

  /// Stops scheduler
  void stop() => _t.cancel();
}
