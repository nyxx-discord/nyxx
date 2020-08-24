part of nyxx;

/// Represents channel with another user.
class DMChannel extends Channel with MessageChannel, ISend implements ITextChannel {
  /// The recipient.
  late User recipient;

  DMChannel._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, 1, client) {
    if (raw["recipients"] != null) {
      this.recipient = User._new(raw["recipients"][0] as Map<String, dynamic>, client);
    } else {
      this.recipient = User._new(raw["recipient"] as Map<String, dynamic>, client);
    }

    this.client.users[this.recipient.id] = recipient;
  }
}
