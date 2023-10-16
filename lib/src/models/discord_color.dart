/// A 24-bit RGB color.
class DiscordColor {
  /// The 24 bit encoding of this color.
  final int value;

  /// The red channel of this color.
  ///
  /// Will be between 0 and 255 inclusive.
  int get r => (value >> 16) & 0xff;

  /// The green channel of this color.
  ///
  /// Will be between 0 and 255 inclusive.
  int get g => (value >> 8) & 0xff;

  /// The blue channel of this color.
  ///
  /// Will be between 0 and 255 inclusive.
  int get b => value & 0xff;

  /// Create a [DiscordColor] from a 24 bit encoded [value].
  const DiscordColor(this.value) : assert(value >= 0 && value <= 0xffffff, 'value must be between 0 and ${0xffffff}');

  /// Create a [DiscordColor] from [r], [g] and [b] channels ranging from 0 to 255 combined.
  ///
  /// [r], [g] and [b] must be positive and less than 256.
  const DiscordColor.fromRgb(int r, int g, int b)
      : assert(r >= 0 && r < 256, 'r must be between 0 and 255'),
        assert(g >= 0 && g < 256, 'g must be between 0 and 255'),
        assert(b >= 0 && b < 256, 'b must be between 0 and 255'),
        value = r << 16 | g << 8 | b;

  /// Create a [DiscordColor] from [r], [g] and [b] channels ranging from 0.0 to 1.0 combined.
  ///
  /// [r], [g] and [b] must be positive and less than or equal to `1.0`.
  factory DiscordColor.fromScaledRgb(double r, double g, double b) {
    assert(r >= 0 && r <= 1, 'r must be between 0 and 1');
    assert(g >= 0 && g <= 1, 'g must be between 0 and 1');
    assert(b >= 0 && b <= 1, 'b must be between 0 and 1');

    return DiscordColor.fromRgb(
      (r * 255).floor(),
      (g * 255).floor(),
      (b * 255).floor(),
    );
  }

  /// Parse a string value to a [DiscordColor].
  ///
  /// [color] must be a valid 6-digit hexadecimal integer, optionally prefixed by a `#` symbol.
  factory DiscordColor.parseHexString(String color) {
    if (color.isEmpty) {
      throw FormatException('Source cannot be empty', color, 0);
    }

    if (color.startsWith('#')) {
      color = color.substring(1);
    }

    if (color.length != 6) {
      throw FormatException('Source must contain 6 hexadecimal digits', color, color.length);
    }

    return DiscordColor(int.parse(color, radix: 16));
  }

  /// Create a new [DiscordColor] identical to this one with one or more channels replaced.
  DiscordColor copyWith({int? r, int? g, int? b}) => DiscordColor.fromRgb(
        r ?? this.r,
        g ?? this.g,
        b ?? this.b,
      );

  /// Convert this [DiscordColor] to a hexadecimal string that can be parsed with
  /// [DiscordColor.parseHexString].
  String toHexString() => '#${value.toRadixString(16).padLeft(6, '0')}'.toUpperCase();

  @override
  String toString() => 'DiscordColor(${toHexString()})';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is DiscordColor && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
