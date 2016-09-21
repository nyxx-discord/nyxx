import '../../objects.dart';
import '../client.dart';

/// Sent when a message is deleted.
class MessageDeleteEvent {
  /// The ID of the message.
  String id;

  /// The message's channel.
  GuildChannel channel;

  /// Constructs a new [MessageDeleteEvent].
  MessageDeleteEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.id = json['d']['id'];
      this.channel = client.channels[json['d']['channel_id']];
      client.emit('messageDelete', this);
    }
  }
}
