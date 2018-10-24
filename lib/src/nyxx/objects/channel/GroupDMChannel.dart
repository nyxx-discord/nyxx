part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  Map<Snowflake, User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw) : super._new(raw, 3) {
    this.recipients = Map<Snowflake, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = User._new(o as Map<String, dynamic>);
      this.recipients[user.id] = user;
    });
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User userId) async {
    await _client._http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");
  }

  @override
  String get nameString => "Group DM Channel [${this.id}] [${recipients.values.map((f) => f.tag).join(", ")}]";
  //"Group DM Channel: ${recipients.values.map((f) => f.tag).join(", ")}";
}
