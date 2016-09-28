import '../../discord.dart';

/// Sent when the client is ready.
class ReadyEvent {
  /// Sends a new ready event.
  ReadyEvent(Client client) {
    client.emit('ready', this);
  }
}
