import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/emoji.dart';
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

  /// Details about this emoji's [count].
  final ReactionCountDetails countDetails;

  /// Whether the current user reacted using this emoji.
  final bool me;

  /// Whether the current user super-reacted using this emoji.
  final bool meBurst;

  /// The emoji for this reaction.
  final PartialEmoji emoji;

  /// The colors used for this the super reaction.
  final List<DiscordColor> burstColors;

  /// {@macro reaction}
  Reaction({
    required this.count,
    required this.countDetails,
    required this.me,
    required this.meBurst,
    required this.emoji,
    required this.burstColors,
  });
}

/// {@template reaction_count_details}
/// Details about a [Reaction]'s [Reaction.count].
/// {@endtemplate}
class ReactionCountDetails with ToStringHelper {
  /// The number of burst reactions.
  final int burst;

  /// The number of normal reactions.
  final int normal;

  /// {@macro reaction_count_details}
  ReactionCountDetails({required this.burst, required this.normal});
}
