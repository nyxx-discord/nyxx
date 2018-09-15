part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  Map<Snowflake, User> recipients;

  GroupDMChannel._new(Map<String, dynamic> data)
      : super._new(data, 3) {
    this.recipients = Map<Snowflake, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = User._new(o as Map<String, dynamic>);
      this.recipients[user.id] = user;
    });
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(Snowflake userId) async {
    await _client
        .http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");
  }
}
