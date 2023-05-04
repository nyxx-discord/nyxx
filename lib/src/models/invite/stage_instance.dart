import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// Represents an invite stage instance.
@Deprecated('This is deprecated')
class InviteStageInstance with ToStringHelper {

  /// The members speaking in the Stage.
  final List<Object /*PartialGuildMember*/> members;

  /// The number of users in the Stage.
  final int participantCount;

  /// The number of users speaking in the Stage.
  final int speakerCount;

  /// The topic of the Stage instance (1-120 characters).
  final String topic;

  /// Create a new [InviteStageInstance].
  const InviteStageInstance({
    required this.members,
    required this.participantCount,
    required this.speakerCount,
    required this.topic,
  });
}
