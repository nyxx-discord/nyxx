import '../../discord.dart';

/// Sent when the client is ready.
class ReadyEvent {
  /// Sends a new ready event.
  ReadyEvent(Client client) {
    client.internal.events.onReady.add(this);
  }
}
