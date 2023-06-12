import 'package:nyxx/src/models/emoji/emoji.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template reaction}
/// A reaction to a message.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#reaction-object
/// {@endtemplate}
class Reaction with ToStringHelper {
  /// The number of times this emoji has been used to react.
  final int count;

  /// Whether the current user reacted using this emoji.
  final bool me;

  final PartialEmoji emoji;

  /// {@macro reaction}
  Reaction({
    required this.count,
    required this.me,
    required this.emoji,
  });
}
