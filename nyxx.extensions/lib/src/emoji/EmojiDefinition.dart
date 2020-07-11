part of nyxx.extensions.emoji;

class EmojiDefinition {
  late final String primaryName;
  late final Iterable<String> names;

  late final String rawEmoji;

  late final Iterable<int> codePoints;

  late final String assetFileName;

  late final String assetUrl;

  EmojiDefinition._new(Map<String, dynamic> raw) {
    this.primaryName = raw["primaryName"] as String;
    this.names = (raw["names"] as Iterable<dynamic>).cast();
    this.rawEmoji = raw["surrogates"] as String;
    this.codePoints = (raw["utf32codepoints"] as Iterable<dynamic>).cast();
    this.assetFileName = raw["assetFileName"] as String;
    this.assetUrl = raw["assetUrl"] as String;
  }

  UnicodeEmoji toEmoji() => UnicodeEmoji(rawEmoji);
}
