part of discord;

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
      this.channel = client.channels.map[json['d']['channel_id']];
      client._events.onMessageDelete.add(this);
    }
  }
}
