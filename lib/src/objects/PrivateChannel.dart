part of discord;

/// A private channel.
class PrivateChannel extends Channel {
  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The recipients.
  Collection recipients;

  PrivateChannel._new(Client client, Map<String, dynamic> data)
      : super._new(client, data, "private") {
    this.lastMessageID = this._map['lastMessageID'] = data['last_message_id'];

    this.recipients = new Collection();
    data['recipients'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(client, o);
      this.recipients.map[user.id] = user;
    });
    this._map['recipients'] = this.recipients;
  }
}
