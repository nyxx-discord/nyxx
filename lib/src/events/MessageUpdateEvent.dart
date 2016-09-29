import '../../discord.dart';

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The updated message.
  Message message;

  /// Constructs a new [MessageUpdateEvent].
  MessageUpdateEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      if (!json['d'].containsKey('embeds')) {
        this.message = new Message(client, json['d'] as Map<String, dynamic>);
        client.emit('messageUpdate', this);
      }
    }
  }
}
