import '../../discord.dart';

/// A private channel.
class PrivateChannel extends Channel {
  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The recipients.
  Collection recipients;

  /// Constructs a new [PrivateChannel].
  PrivateChannel(Client client, Map<String, dynamic> data)
      : super(client, data, "private") {
    this.lastMessageID = this.map['lastMessageID'] = data['last_message_id'];

    this.recipients = new Collection();
    data['recipients'].forEach((Map<String, dynamic> o) {
      final User user = new User(client, o);
      this.recipients.map[user.id] = user;
    });
    this.map['recipients'] = this.recipients;
  }
}
