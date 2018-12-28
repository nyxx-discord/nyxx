part of nyxx;

/// Reaction object. [emoji] field can be partial [GuildEmoji].
class Reaction {
  /// Time this emoji has been used to react
  int count;

  ///	Whether the current user reacted using this emoji
  bool me;

  /// Emoji information
  Emoji emoji;

  Reaction._new(Map<String, dynamic> raw) {
    count = raw['count'] as int;
    me = raw['me'] as bool;

    var rawEmoji = raw['emoji'] as Map<String, dynamic>;
    if (rawEmoji['id'] == null)
      emoji = UnicodeEmoji(rawEmoji['name'] as String);
    else
      emoji = GuildEmoji._partial(rawEmoji);
  }

  Reaction._event(this.emoji, this.me) {
    count = 1;
  }
}
