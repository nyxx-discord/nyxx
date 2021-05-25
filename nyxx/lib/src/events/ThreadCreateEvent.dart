part of nyxx;

/// Fired when a thread is created
class ThreadCreateEvent {
  /// The thread that was just created
  late final ThreadChannel thread;

  ThreadCreateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.thread = ThreadChannel._new(client, raw["d"] as Map<String, dynamic>);
  }
}
