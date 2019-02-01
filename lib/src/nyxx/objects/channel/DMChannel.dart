part of nyxx;

/// Represents channel with another user.
class DMChannel extends MessageChannel {
  /// The recipient.
  User recipient;

  DMChannel._new(Map<String, dynamic> raw, Nyxx client)
      : super._new(raw, 4, client) {
    if (raw['recipients'] != null) {
      this.recipient =
          User._new(raw['recipients'][0] as Map<String, dynamic>, client);
    } else {
      this.recipient =
          User._new(raw['recipient'] as Map<String, dynamic>, client);
    }
  }

  @override
  String get debugString => "DM Channel [${this.id}] [${this.recipient.tag}]";
}
