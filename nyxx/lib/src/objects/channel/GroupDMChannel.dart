part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  final  Map<Snowflake, User> recipients = Map();

  GroupDMChannel._new(Map<String, dynamic> raw, Nyxx client)
      : super._new(raw, 3, client) {

    for(var o in raw['recipients']) {
      User user = User._new(o as Map<String, dynamic>, client);
      this.recipients[user.id] = user;
    }
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User userId) {
    return client._http
        ._execute(JsonRequest._new("/channels/${this.id}/recipients/${userId.toString()}", method: "DELETE"));
  }
}
