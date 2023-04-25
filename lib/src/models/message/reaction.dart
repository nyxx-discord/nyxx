/// {@template reaction}
/// A reaction to a message.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#reaction-object
/// {@endtemplate}
class Reaction {
  /// The number of times this emoji has been used to react.
  final int count;

  /// Whether the current user reacted using this emoji.
  final bool me;

  // TODO
  //final PartialEmoji emoji;

  /// {@macro reaction}
  Reaction({
    required this.count,
    required this.me,
  });
}
