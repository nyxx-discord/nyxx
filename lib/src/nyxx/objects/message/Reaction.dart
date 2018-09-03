part of nyxx;

/// Reaction object, has partial [GuildEmoji] object (only id, and name (for unicode emoji 'id' is null))
class Reaction {
  /// Time this emoji has ben used to react
  int count;

  ///	Whether the current user reacted using this emoji
  bool me;

  /// Emoji information
  Emoji emoji;

  /// Raw response data
  Map<String, dynamic> raw;

  Reaction._new(this.raw) {
    count = raw['count'] as int;
    me = raw['me'] as bool;

    var rawEmoji = raw['emoji'] as Map<String, dynamic>;
    if (rawEmoji['id'] == null)
      emoji = UnicodeEmoji._partial(rawEmoji['name'] as String);
    else
      emoji = GuildEmoji._partial(rawEmoji);
  }
}
