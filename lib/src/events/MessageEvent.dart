import '../../discord.dart';

/// Sent when a new message is received.
class MessageEvent {
  /// The new message.
  Message message;

  /// Constucts a new [MessageEvent].
  MessageEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.message = new Message(client, json['d']);
      client.emit('message', this);
    }
  }
}
