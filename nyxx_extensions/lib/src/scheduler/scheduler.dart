import "dart:async";

import "package:nyxx/nyxx.dart" show Nyxx;

/// Callback for [ScheduledEvent]. Is executed every period given in [ScheduledEvent]
typedef ScheduledEventCallback = Future<void> Function(Nyxx, Timer);

/// Creates and starts new periodic event. [callback] will be executed every given duration of time.
/// Event can be stopped via [stop] function.
class ScheduledEvent {
  /// [Nyxx] instance
  final Nyxx client;

  /// Callback which will be run every given period of time
  final ScheduledEventCallback callback;

  late final Timer _timer;

  /// Creates and starts new periodic event. [callback] will be executed every [duration] of time.
  /// Event can be stopped via [stop] function.
  ScheduledEvent(this.client, Duration duration, this.callback) {
    _timer = Timer.periodic(duration, (timer) => callback(client, timer));
  }

  /// Stops [ScheduledEvent] if running.
  void stop() => _timer.cancel();
}
