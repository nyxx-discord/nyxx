import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The status of processing the target users for an invite.
///
/// {@category models}
class InviteTargetsJobStatus with ToStringHelper {
  /// The type of this status.
  final InviteTargetsJobStatusType status;

  /// The total number of users to process.
  final int totalUsers;

  /// The total number of users processed so far.
  final int processedUsers;

  /// The time at which this job was created.
  final DateTime createdAt;

  /// The time at which this job was completed.
  final DateTime? completedAt;

  /// If this job encountered a failure, a message explaining the reason why.
  final String? errorMessage;

  /// @nodoc
  InviteTargetsJobStatus({
    required this.status,
    required this.totalUsers,
    required this.processedUsers,
    required this.createdAt,
    required this.completedAt,
    required this.errorMessage,
  });
}

/// The type of an [InviteTargetsJobStatus].
final class InviteTargetsJobStatusType extends EnumLike<int, InviteTargetsJobStatusType> {
  static const unspecified = InviteTargetsJobStatusType(0);
  static const processing = InviteTargetsJobStatusType(1);
  static const completed = InviteTargetsJobStatusType(2);
  static const failed = InviteTargetsJobStatusType(3);

  /// @nodoc
  const InviteTargetsJobStatusType(super.value);
}
