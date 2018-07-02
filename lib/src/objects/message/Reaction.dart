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
    count = raw['count'];
    me = raw['me'];

    var rawEmoji = raw['emoji'] as Map<String, dynamic>;
    if (rawEmoji['id'] == null)
      emoji = new UnicodeEmoji._partial(rawEmoji['name']);
    else
      emoji = new GuildEmoji._partial(rawEmoji);
  }
}
