import 'package:nyxx/src/core/message/Emoji.dart';

abstract class IUnicodeEmoji implements IEmoji {
  /// Codepoint for emoji
  String get code;
}

/// Represents unicode emoji. Contains only emoji code.
class UnicodeEmoji implements IUnicodeEmoji, IEmoji {
  /// Codepoint for emoji
  @override
  final String code;

  /// Constructs new Unicode emoji from given [String]
  UnicodeEmoji(this.code);

  @override
  String formatForMessage() => this.code;

  @override
  String encodeForAPI() => this.code;

  @override
  String toString() => this.formatForMessage();
}
