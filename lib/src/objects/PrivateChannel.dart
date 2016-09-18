import '../../discord.dart';

/// A private channel.
class PrivateChannel {

  /// The channel's ID.
  String id;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// Always false representing that it is a PrivateChannel.
  bool isPrivate = true;

  /// A timestamp for when the channel was created.
  double createdAt;

  /// The recipients.
  List<User> recipients = [];

  PrivateChannel(Map data) {
    this.id = data['id'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.lastMessageID = data['last_message_id'];

    data['recipients'].forEach((o) {
      this.recipients.add(new User(o));
    });
  }
}
