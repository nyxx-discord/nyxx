part of nyxx;

/// Reaction object. [emoji] field can be partial [GuildEmoji].
class Reaction {
  /// Time this emoji has been used to react
  late int count;

  ///	Whether the current user reacted using this emoji
  late final bool me;

  /// Emoji information
  late final Emoji emoji;

  Reaction._new(Map<String, dynamic> raw) {
    this.count = raw['count'] as int;
    this.me = raw['me'] as bool;

    var rawEmoji = raw['emoji'] as Map<String, dynamic>;
    if (rawEmoji['id'] == null) {
      this.emoji = UnicodeEmoji(rawEmoji['name'] as String);
    } else {
      this.emoji = GuildEmoji._partial(rawEmoji);
    }
  }

  Reaction._event(this.emoji, this.me) {
    count = 1;
  }
}
