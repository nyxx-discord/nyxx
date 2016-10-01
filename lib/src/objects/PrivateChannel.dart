import '../../discord.dart';

/// A private channel.
class PrivateChannel {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The channel's ID.
  String id;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// Always false representing that it is a PrivateChannel.
  bool isPrivate = true;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  /// The recipients.
  Collection recipients;

  /// Constructs a new [PrivateChannel].
  PrivateChannel(this.client, Map<String, dynamic> data) {
    this.id = this.map['id'] = data['id'];
    this.createdAt =
        this.map['createdAt'] = this.client.internal.util.getDate(this.id);
    this.lastMessageID = this.map['lastMessageID'] = data['last_message_id'];

    this.recipients = new Collection();
    data['recipients'].forEach((Map<String, dynamic> o) {
      final User user = new User(client, o);
      this.recipients.map[user.id] = user;
    });
    this.map['recipients'] = this.recipients;
  }
}
