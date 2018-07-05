part of nyxx;

class GroupDMChannel extends MessageChannel {
  /// The recipients.
  Map<String, User> recipients;

  GroupDMChannel._new(Client client, Map<String, dynamic> data)
      : super._new(client, data, "private") {
    this.lastMessageID = raw['last_message_id'];
    this.messages = new LinkedHashMap<String, Message>();

    this.recipients = new Map<String, User>();
    raw['recipients'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(client, o);
      this.recipients[user.id] = user;
    });
  }
}
