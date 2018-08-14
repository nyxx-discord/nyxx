part of nyxx;

/// Represents group DM channel
class GroupDMChannel extends MessageChannel {
  /// The recipients.
  Map<Snowflake, User> recipients;

  GroupDMChannel._new(Client client, Map<String, dynamic> data)
      : super._new(client, data, "private") {
    this.recipients = new Map<Snowflake, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = new User._new(client, o as Map<String, dynamic>);
      this.recipients[user.id] = user;
    });
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(Snowflake userId) async {
    await this
        .client
        .http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");
  }
}
