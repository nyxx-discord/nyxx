import '../../objects.dart';
import '../client.dart';

/// Sent when a new message is received.
class MessageEvent {
  /// The new message.
  Message message;

  MessageEvent(Client client, Map json) {
    if (client.ready) {
      this.message = new Message(client, json['d']);
      client.emit('message', this);
    }
  }
}
