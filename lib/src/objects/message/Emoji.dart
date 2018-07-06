part of nyxx;

/// Represents emoji. Subclasses provides abstraction to custom emojis(like [GuildEmoji]).
abstract class Emoji {
  /// Emojis name.
  String name;

  Emoji(this.name);

  String encode();

  bool operator ==(other) => other is Emoji && other.name == this.name;

  int get hashCode => 17 * 37 + name.hashCode;
}
