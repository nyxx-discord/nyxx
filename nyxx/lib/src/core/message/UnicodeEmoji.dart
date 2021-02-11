part of nyxx;

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji implements IEmoji {
  /// Codepoint for emoji
  final String code;

  /// Constructs new Unicode emoji from given [String]
  UnicodeEmoji(this.code);

  @override
  String formatForMessage() =>
      this.code;

  @override
  String encodeForAPI() =>
      this.code;

  @override
  String toString() => this.formatForMessage();
}
