part of nyxx;

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji extends Emoji {
  /// Emoji's unicode code. Hexadecimal number;
  String code;

  UnicodeEmoji(this.code, String name) : super(name);
  UnicodeEmoji._new(this.code, String name) : super(name);
  UnicodeEmoji._partial(this.code) : super("");

  /// Encodes Emoji so that can be used in messages.
  @override
  String encode() {
    try {
      return new String.fromCharCode(int.parse(code, radix: 16));
    } catch (e) {
      return code;
    }
  }

  /// Returns encoded string ready to send via message.
  @override
  String toString() => encode();

  @override
  String format() => encode();

  @override
  bool operator ==(other) => other is Emoji && other.name == this.name;

  @override
  int get hashCode => super.hashCode * 37 + code.hashCode;
}
