part of nyxx;

/// Represents emoji. Subclasses provides abstraction to custom emojis(like [GuildEmoji]).
abstract class Emoji {
  /// Emojis name.
  String name;

  Emoji(this.name);

  // TODO: Emojis stuff
  factory Emoji._deserialize(Map<String, dynamic> raw) {
    return UnicodeEmoji(raw["name"] as String);
  }

  /// Encodes Emoji to API format
  String encode();

  /// Created message ready Emoji
  String format();

  @override
  bool operator ==(other) => other is Emoji && other.name == this.name;

  @override
  int get hashCode => 17 * 37 + name.hashCode;
}
