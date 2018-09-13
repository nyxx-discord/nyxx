part of nyxx;

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji extends Emoji {
  /// Emoji itself.
  String code;

  UnicodeEmoji(this.code) : super("");

  /// Encodes Emoji so that can be used in messages.
  @override
  String encode() => code;

  /// Returns encoded string ready to send via message.
  @override
  String toString() => encode();

  @override
  String format() => encode();

  @override
  bool operator ==(other) {
    if (other is UnicodeEmoji) return other.code == this.code;
    if (other is String) return other == this.code;

    return false;
  }

  @override
  int get hashCode => super.hashCode * 37 + code.hashCode;
}
