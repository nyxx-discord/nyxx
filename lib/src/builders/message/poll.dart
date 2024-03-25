import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/message/poll.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@macro poll_media}
class PollMediaBuilder extends CreateBuilder<PollMedia> {
  /// The text of the field.
  String? text;

  /// The emoji of the field.
  Emoji? emoji;

  PollMediaBuilder({this.text, this.emoji});

  @override
  Map<String, Object?> build() => {
        if (text != null) 'text': text,
        if (emoji != null)
          'emoji': {
            'id': emoji!.id == Snowflake.zero ? null : emoji!.id.toString(),
            'name': emoji!.name,
            if (emoji is GuildEmoji) 'animated': (emoji as GuildEmoji).isAnimated == true,
          },
      };
}

/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/poll#poll-answer-object
class PollAnswerBuilder extends CreateBuilder<PollAnswer> {
  /// The data of the answer.
  PollMediaBuilder pollMedia;

  PollAnswerBuilder({required this.pollMedia});

  PollAnswerBuilder.text(String text, [Emoji? emoji]) : pollMedia = PollMediaBuilder(text: text, emoji: emoji);

  @override
  Map<String, Object?> build() => {'poll_media': pollMedia.build()};
}

/// {@macro poll}
class PollBuilder extends CreateBuilder<Poll> {
  /// The question of the poll. Only [PollMediaBuilder.text] is supported.
  PollMediaBuilder question;

  /// Each of the answers available in the poll.
  List<PollAnswerBuilder> answers;

  /// Number of hours the poll should be open for, up to 7 days.
  Duration duration;

  /// Whether a user can select multiple answers.
  bool? allowMultiselect;

  /// The layout type of the poll.
  PollLayoutType? layoutType;

  PollBuilder({
    required this.question,
    required this.answers,
    required this.duration,
    this.allowMultiselect,
    this.layoutType,
  });

  @override
  Map<String, Object?> build() => {
        'question': question.build(),
        'answers': answers.map((a) => a.build()).toList(),
        'duration': duration.inHours,
        if (allowMultiselect != null) 'allow_multiselect': allowMultiselect,
        if (layoutType != null) 'layout_type': layoutType!.value,
      };
}
