part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  Map<Snowflake, User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, 3, client) {
    this.recipients = Map<Snowflake, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = User._new(o as Map<String, dynamic>, client);
      this.recipients[user.id] = user;
    });
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User userId) async {
    await client._http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");
  }

  @override
  String get debugString =>
      "Group DM Channel [${this.id}] [${recipients.values.map((f) => f.tag).join(", ")}]";
  //"Group DM Channel: ${recipients.values.map((f) => f.tag).join(", ")}";
}
