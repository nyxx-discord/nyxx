part of nyxx;

/// Represents channel with another user.
class DMChannel extends MessageChannel {
  /// The recipient.
  User recipient;

  DMChannel._new(Map<String, dynamic> data)
      : super._new(data, 4) {
    if (raw['recipients'] != null) {
      this.recipient =
          User._new(raw['recipients'][0] as Map<String, dynamic>);
    } else {
      this.recipient =
          User._new(raw['recipient'] as Map<String, dynamic>);
    }
  }
}
