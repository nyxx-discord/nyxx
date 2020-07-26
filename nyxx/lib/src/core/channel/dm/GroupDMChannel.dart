part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends Channel with MessageChannel, ISend implements ITextChannel {
  /// The recipients of channel.
  late final List<User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, 3, client) {
    this.recipients = [for (var o in raw["recipients"]) User._new(o as Map<String, dynamic>, client)];
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User user) =>
    client._http._execute(BasicRequest._new("/channels/${this.id}/recipients/${user.id}", method: "DELETE"));
}
