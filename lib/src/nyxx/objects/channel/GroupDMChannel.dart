part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  Map<Snowflake, User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw)
      : super._new(raw, 3) {
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

  @override
  String toString() => "Group DM Channel: ${recipients.values.map((f) => f.toString()).join(", ")}";
}
