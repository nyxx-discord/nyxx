
/// Provides color utilities
class Color {
  /// Converts RGB values to int
  static int RGBtoInt(int red, int green, int blue)
    => (red << 16) | (green << 8) | blue;

  /// Converts RGB hex string into int value
  static int HEXtoInt(String hex) {
    hex = hex.replaceAll("#", " ");
    int R = int.parse(hex.substring(0, 3), radix: 16);
    int G = int.parse(hex.substring(3, 5), radix: 16);
    int B = int.parse(hex.substring(5), radix: 16);

    return RGBtoInt(R, G, B);
  }
}