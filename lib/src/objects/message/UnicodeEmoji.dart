part of nyxx;

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji extends Emoji {
  /// Emoji's unicode code. Hexadecimal number;
  String code;

  UnicodeEmoji._new(this.code, String name) : super(name);
  UnicodeEmoji._partial(this.code) : super("");

  /// Encodes Emoji so that can be used in messages.
  String encode() => new String.fromCharCode(int.parse(code, radix: 16));

  /// Returns encoded string ready to send via message.
  String toString() => encode();
  bool operator ==(other) => other is Emoji && other.name == this.name;
}
