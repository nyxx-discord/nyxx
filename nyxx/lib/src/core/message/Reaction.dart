part of nyxx;

/// Reaction object. [emoji] field can be partial [GuildEmoji].
class Reaction {
  /// Time this emoji has been used to react
  late int count;

  ///	Whether the current user reacted using this emoji
  late final bool me;

  /// Emoji information
  late final IEmoji emoji;

  Reaction._new(RawApiMap raw) {
    this.count = raw["count"] as int;
    this.me = raw["me"] as bool;

    final rawEmoji = raw["emoji"] as RawApiMap;
    if (rawEmoji["id"] == null) {
      this.emoji = UnicodeEmoji(rawEmoji["name"] as String);
    } else {

      //TODO: EMOJIS STUUF
      //this.emoji = PartialGuildEmoji._new(rawEmoji);
    }
  }

  Reaction._event(this.emoji, this.me) {
    count = 1;
  }
}
