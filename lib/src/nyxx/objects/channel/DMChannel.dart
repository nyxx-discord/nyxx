part of nyxx;

/// Represents channel with another user.
class DMChannel extends MessageChannel {
  /// The recipient.
  User recipient;

  DMChannel._new(Map<String, dynamic> raw) : super._new(raw, 4) {
    if (raw['recipients'] != null) {
      this.recipient = User._new(raw['recipients'][0] as Map<String, dynamic>);
    } else {
      this.recipient = User._new(raw['recipient'] as Map<String, dynamic>);
    }
  }

  @override
  String toString() => "DM CHANNEL: ${recipient.toString()}";
}
