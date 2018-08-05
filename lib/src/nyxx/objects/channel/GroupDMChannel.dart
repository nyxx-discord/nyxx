part of nyxx;

class GroupDMChannel extends MessageChannel {
  /// The recipients.
  Map<String, User> recipients;

  GroupDMChannel._new(Client client, Map<String, dynamic> data)
      : super._new(client, data, "private") {

    this.recipients = new Map<String, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = new User._new(client, o as Map<String, dynamic>);
      this.recipients[user.id.toString()] = user;
    });
  }

  Future<Null> removeRecipient(Snowflake userId) async {
    await this
        .client
        .http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");

    return null;
  }
}
