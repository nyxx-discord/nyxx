import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A layout type indicating how poll looks.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#layout-type
enum PollLayoutType {
  /// The default layout type.
  defaultLayout._(1);

  /// The value of this [PollLayoutType].
  final int value;

  const PollLayoutType._(this.value);

  /// Parse an [PollLayoutType] from an [int].
  ///
  /// The [value] must be a valid poll layout type.
  factory PollLayoutType.parse(int value) => PollLayoutType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown PollLayoutType', value),
      );

  @override
  String toString() => 'PollLayoutType($value)';
}

/// {@template poll_media}
/// The poll media object is a common object that backs both the question and answers.
/// The intention is that it allows us to extensibly add new ways to display things in the future.
/// For now, [Poll.question] only supports [PollMedia.text], while answers can have an optional [PollMedia.emoji].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#poll-media-object
/// {@endtemplate}
class PollMedia with ToStringHelper {
  /// The text of the field.
  String? text;

  /// The emoji of the field.
  Emoji? emoji;

  /// {@macro poll_media}
  /// @nodoc
  PollMedia({required this.text, required this.emoji});
}

/// {@template poll_answer}
/// The [PollAnswer.answerId] is a number that labels each answer.
/// As an implementation detail, it currently starts at 1 for the first answer and goes up sequentially.
/// We recommend against depending on this sequence.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#poll-answer-object
/// {@endtemplate}
class PollAnswer with ToStringHelper {
  /// The ID of the answer.
  final int answerId;

  /// The data of the answer.
  PollMedia pollMedia;

  /// {@macro poll_answer}
  /// @nodoc
  PollAnswer({required this.answerId, required this.pollMedia});
}

class PollAnswerCount with ToStringHelper {
  /// The ID of the answer.
  final int answerId;

  /// The number of votes for this answer.
  final int count;

  /// Whether the current user voted for this answer.
  final bool me;

  /// @nodoc
  PollAnswerCount({required this.answerId, required this.count, required this.me});
}

/// {@template poll_results}
/// In a nutshell, this contains the number of votes for each answer.
/// Due to the intricacies of counting at scale, while a poll is in progress the results may not be perfectly accurate.
/// They usually are accurate, and shouldn't deviate significantly -- it's just difficult to make guarantees.
/// To compensate for this, after a poll is finished there is a background job which performs a final, accurate tally of votes.
/// This tally has concluded once [PollResults.isFinalized] is `true`.
/// If [PollResults.answerCounts] does not contain an entry for a particular answer, then there are no votes for that answer.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#poll-results-object
/// {@endtemplate}
class PollResults with ToStringHelper {
  /// Whether the votes have been precisely counted.
  final bool isFinalized;

  /// The counts for each answer.
  final List<PollAnswerCount> answerCounts;

  /// {@macro poll_results}
  /// @nodoc
  PollResults({required this.isFinalized, required this.answerCounts});
}

/// {@template poll}
/// The poll object has a lot of levels and nested structures. It was also designed
/// to support future extensibility, so some fields may appear to be more complex than
/// necessary.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#poll-object
/// {@endtemplate}
class Poll with ToStringHelper {
  /// The question of the poll.
  final PollMedia question;

  /// Each of the answers available in the poll.
  final List<PollAnswer> answers;

  /// The time when the poll ends.
  final DateTime? endsAt;

  /// Whether a user can select multiple answers.
  final bool allowsMultiselect;

  /// The layout type of the poll.
  final PollLayoutType layoutType;

  /// The results of the poll.
  final PollResults? results;

  /// {@macro poll}
  /// @nodoc
  Poll({required this.question, required this.answers, required this.endsAt, required this.allowsMultiselect, required this.layoutType, required this.results});
}
