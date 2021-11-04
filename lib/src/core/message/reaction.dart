import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IReaction {
  /// Time this emoji has been used to react
  int get count;

  ///	Whether the current user reacted using this emoji
  bool get me;

  /// Emoji information
  IEmoji get emoji;
}

/// Reaction object. [emoji] field can be partial [GuildEmoji].
class Reaction implements IReaction {
  /// Time this emoji has been used to react
  @override
  late int count;

  ///	Whether the current user reacted using this emoji
  @override
  late final bool me;

  /// Emoji information
  @override
  late final IEmoji emoji;

  /// Creates an instance of [Reaction]
  Reaction(RawApiMap raw) {
    count = raw["count"] as int;
    me = raw["me"] as bool;

    final rawEmoji = raw["emoji"] as RawApiMap;
    if (rawEmoji["id"] == null) {
      emoji = UnicodeEmoji(rawEmoji["name"] as String);
    } else {
      //TODO: EMOJIS STUUF
      //this.emoji = PartialGuildEmoji._new(rawEmoji);
    }
  }

  /// Creates na instance of [Reaction]
  Reaction.event(this.emoji, this.me) {
    count = 1;
  }
}
