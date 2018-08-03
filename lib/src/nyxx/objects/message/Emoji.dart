part of nyxx;

/// Represents emoji. Subclasses provides abstraction to custom emojis(like [GuildEmoji]).
abstract class Emoji {
  /// Emojis name.
  String name;

  Emoji(this.name);

  /// Encodes Emoji to API format
  String encode();

  /// Created message ready Emoji
  String format();

  bool operator ==(other) => other is Emoji && other.name == this.name;

  int get hashCode => 17 * 37 + name.hashCode;
}
