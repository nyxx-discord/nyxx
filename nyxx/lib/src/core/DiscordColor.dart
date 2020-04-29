part of nyxx;

/// Wrapper for colors.
///
/// Simplifies creation and provides interface to interact with colors for nyxx.
class DiscordColor {
  late final int _value;

  /// Construct color from int.
  /// It allows to create color from hex number and decimal number
  ///
  /// ```
  /// var color = DiscordColor.fromInt(43563);
  /// var color2 = DiscordColor.fromInt(0xff0044);
  /// ```
  DiscordColor.fromInt(int color) {
    this._value = color;
  }

  /// Construct color from individual color components
  DiscordColor.fromRgb(int r, int g, int b) {
    this._value = r << 16 | g << 8 | b;
  }

  /// Construct color from individual color components with doubles
  /// Values should be from 0.0 to 1.0
  DiscordColor.fromDouble(double r, double g, double b) {
    var rb = (r * 255).toInt();
    var gb = (g * 255).toInt();
    var bb = (b * 255).toInt();

    this._value = rb << 16 | gb << 8 | bb;
  }

  /// Construct color from hex String.
  /// Leading # will be ignored in process.
  DiscordColor.fromHexString(String hexStr) {
    if (hexStr.isEmpty)
      throw new ArgumentError("Hex color String cannot be empty");

    if (hexStr.startsWith("#")) hexStr = hexStr.substring(1);

    this._value = int.parse(hexStr, radix: 16);
  }

  /// Int value of color
  int get value => _value;

  /// Gets the blue component of this color as an integer.
  int get r => ((this._value >> 16) & 0xFF);

  /// Gets the green component of this color as an integer.
  int get g => ((this._value >> 8) & 0xFF);

  /// Gets the blue component of this color as an integer.
  int get b => (this._value & 0xFF);

  @override
  String toString() => "#${_value.toRadixString(16)}";

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) =>
      other is DiscordColor && other._value == this._value;

  // All colors got from DiscordColor class from DSharp+.
  // https://github.com/DSharpPlus/DSharpPlus/blob/a2f6eca7f5f675e83748b20b957ae8bdb8fd0cab/DSharpPlus/Entities/DiscordColor.Colors.cs

  /// Color of null, literally null.
  static final DiscordColor? none = null;

  /// A near-black color. Due to API limitations, the color is #010101, rather than #000000, as the latter is treated as no color.
  static final DiscordColor black = DiscordColor.fromInt(0x010101);

  /// White, or #FFFFFF.
  static final DiscordColor white = DiscordColor.fromInt(0xFFFFFF);

  /// Gray, or #808080.
  static final DiscordColor gray = DiscordColor.fromInt(0x808080);

  /// Dark gray, or #A9A9A9.
  static final DiscordColor darkGray = DiscordColor.fromInt(0xA9A9A9);

  /// Light gray, or #808080.
  static final DiscordColor lightGray = DiscordColor.fromInt(0xD3D3D3);

  /// Very dark gray, or #666666.
  static final DiscordColor veryDarkGray = DiscordColor.fromInt(0x666666);

  /// Flutter blue, or #02569B
  static final DiscordColor flutterBlue = DiscordColor.fromInt(0x02569B);

  /// Dart's primary blue color, or #0175C2
  static final DiscordColor dartBlue = DiscordColor.fromInt(0x0175C2);

  ///  Dart's secondary blue color, or #13B9FD
  static final DiscordColor dartSecondary = DiscordColor.fromInt(0x13B9FD);

  /// Discord Blurple, or #7289DA.
  static final DiscordColor blurple = DiscordColor.fromInt(0x7289DA);

  /// Discord Grayple, or #99AAB5.
  static final DiscordColor grayple = DiscordColor.fromInt(0x99AAB5);

  /// Discord Dark, But Not Black, or #2C2F33.
  static final DiscordColor darkButNotBlack = DiscordColor.fromInt(0x2C2F33);

  /// Discord Not QuiteBlack, or #23272A.
  static final DiscordColor notQuiteBlack = DiscordColor.fromInt(0x23272A);

  /// Red, or #FF0000.
  static final DiscordColor red = DiscordColor.fromInt(0xFF0000);

  /// Dark red, or #7F0000.
  static final DiscordColor darkRed = DiscordColor.fromInt(0x7F0000);

  /// Green, or #00FF00.
  static final DiscordColor green = DiscordColor.fromInt(0x00FF00);

  /// Dark green, or #007F00.
  static final DiscordColor darkGreen = DiscordColor.fromInt(0x007F00);

  /// Blue, or #0000FF.
  static final DiscordColor blue = DiscordColor.fromInt(0x0000FF);

  /// Dark blue, or #00007F.
  static final DiscordColor darkBlue = DiscordColor.fromInt(0x00007F);

  /// Yellow, or #FFFF00.
  static final DiscordColor yellow = DiscordColor.fromInt(0xFFFF00);

  /// Cyan, or #00FFFF.
  static final DiscordColor cyan = DiscordColor.fromInt(0x00FFFF);

  /// Magenta, or #FF00FF.
  static final DiscordColor magenta = DiscordColor.fromInt(0xFF00FF);

  /// Teal, or #008080.
  static final DiscordColor teal = DiscordColor.fromInt(0x008080);

  /// Aquamarine, or #00FFBF.
  static final DiscordColor aquamarine = DiscordColor.fromInt(0x00FFBF);

  /// Gold, or #FFD700.
  static final DiscordColor gold = DiscordColor.fromInt(0xFFD700);

  /// Goldenrod, or #DAA520
  static final DiscordColor goldenrod = DiscordColor.fromInt(0xDAA520);

  /// Azure, or #007FFF.
  static final DiscordColor azure = DiscordColor.fromInt(0x007FFF);

  /// Rose, or #FF007F.
  static final DiscordColor rose = DiscordColor.fromInt(0xFF007F);

  /// Spring green, or #00FF7F.
  static final DiscordColor springGreen = DiscordColor.fromInt(0x00FF7F);

  /// Chartreuse, or #7FFF00.
  static final DiscordColor chartreuse = DiscordColor.fromInt(0x7FFF00);

  /// Orange, or #FFA500.
  static final DiscordColor orange = DiscordColor.fromInt(0xFFA500);

  /// Purple, or #800080.
  static final DiscordColor purple = DiscordColor.fromInt(0x800080);

  /// Violet, or #EE82EE.
  static final DiscordColor violet = DiscordColor.fromInt(0xEE82EE);

  /// Brown, or #A52A2A.
  static final DiscordColor brown = DiscordColor.fromInt(0xA52A2A);

  /// Hot pink, or #FF69B4
  static final DiscordColor hotPink = DiscordColor.fromInt(0xFF69B4);

  /// Lilac, or #C8A2C8.
  static final DiscordColor lilac = DiscordColor.fromInt(0xC8A2C8);

  /// Cornflower blue, or #6495ED.
  static final DiscordColor cornflowerBlue = DiscordColor.fromInt(0x6495ED);

  /// Midnight blue, or #191970.
  static final DiscordColor midnightBlue = DiscordColor.fromInt(0x191970);

  /// Wheat, or #F5DEB3.
  static final DiscordColor wheat = DiscordColor.fromInt(0xF5DEB3);

  /// Indian red, or #CD5C5C.
  static final DiscordColor indianRed = DiscordColor.fromInt(0xCD5C5C);

  /// Turquoise, or #30D5C8.
  static final DiscordColor turquoise = DiscordColor.fromInt(0x30D5C8);

  /// Sap green, or #507D2A.
  static final DiscordColor sapGreen = DiscordColor.fromInt(0x507D2A);

  /// Phthalo blue, or #000F89.
  static final DiscordColor phthaloBlue = DiscordColor.fromInt(0x000F89);

  /// Phthalo green, or #123524.
  static final DiscordColor phthaloGreen = DiscordColor.fromInt(0x123524);

  /// Sienna, or #882D17.
  static final DiscordColor sienna = DiscordColor.fromInt(0x882D17);
}
