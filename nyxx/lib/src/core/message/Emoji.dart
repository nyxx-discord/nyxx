part of nyxx;

/// Represents emoji. Subclasses provides abstraction to custom emojis(like [GuildEmoji]).
abstract class IEmoji {
  /// Returns encoded emoji for API usage
  String encodeForAPI();

  /// Returns encoded emoji for usage in message
  String formatForMessage();
}