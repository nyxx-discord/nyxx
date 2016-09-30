import '../../discord.dart';

/// Sent when the client is ready.
class ReadyEvent {
  /// Sends a new ready event.
  ReadyEvent(Client client) {
    client.events.onReady.add(this);
  }
}
