part of nyxx;

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji extends Emoji {
  /// Create unicode emoji from given code
  UnicodeEmoji(String name) : super._new(name);

  /// Returns Emoji
  String get code => this.name!;

  /// Returns runes of emoji
  Runes get runes => this.name!.runes;

  /// Encodes Emoji so that can be used in messages.
  @override
  String encode() => this.name!;

  /// Returns encoded string ready to send via message.
  @override
  String toString() => encode();

  @override
  String format() => encode();

  @override
  bool operator ==(other) {
    if (other is UnicodeEmoji) return other.name == this.name;
    if (other is String) return other == this.name;

    return false;
  }

  @override
  int get hashCode => super.hashCode * 37 + name.hashCode;
}
