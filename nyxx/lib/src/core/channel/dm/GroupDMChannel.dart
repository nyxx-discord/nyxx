part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends Channel with MessageChannel, ISend implements ITextChannel {
  /// The recipients of channel.
  late final List<User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, 3, client) {
    for(final rawObj in raw["recipients"]) {
      final user = User._new(rawObj as Map<String, dynamic>, client);
      this.recipients.add(user);
      this.client.users[user.id] = user;
    }
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User user) =>
    client._http._execute(BasicRequest._new("/channels/${this.id}/recipients/${user.id}", method: "DELETE"));
}
