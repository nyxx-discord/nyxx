import '../../discord.dart';

/// A private channel.
class PrivateChannel {
  /// The channel's ID.
  String id;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// Always false representing that it is a PrivateChannel.
  bool isPrivate = true;

  /// A timestamp for when the channel was created.
  double createdAt;

  /// The recipients.
  List<User> recipients = <User>[];

  /// Constructs a new [PrivateChannel].
  PrivateChannel(Map<String, dynamic> data) {
    this.id = data['id'];
    this.map['id'] = this.id;

    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.map['createdAt'] = this.createdAt;

    this.lastMessageID = data['last_message_id'];
    this.map['lastMessageID'] = this.lastMessageID;


    data['recipients'].forEach((Map<String, dynamic> o) {
      this.recipients.add(new User(o));
    });
    this.map['recipients'] = this.recipients;
  }
}
