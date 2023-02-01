import 'package:nyxx/src/utils/permissions.dart';

/// The flags associated with a member.
abstract class IMemberFlags {
  /// Whether the member has left and rejoined the guild.
  bool get didRejoin;

  /// Whether the member has completed onboarding.
  bool get completedOnboarding;

  /// Whether the member is exempt from guild verification requirements.
  bool get bypassesVerification;

  /// Wether the member has started onboarding.
  bool get startedOnBoarding;
}

class MemberFlags implements IMemberFlags {
  @override
  bool get didRejoin => PermissionsUtils.isApplied(raw, 1 << 0);

  @override
  bool get completedOnboarding => PermissionsUtils.isApplied(raw, 1 << 1);

  @override
  bool get bypassesVerification => PermissionsUtils.isApplied(raw, 1 << 2);

  @override
  bool get startedOnBoarding => PermissionsUtils.isApplied(raw, 1 << 3);

  final int raw;

  const MemberFlags(this.raw);

  @override
  String toString() => 'MemberFlags(didRejoin: $didRejoin,'
      ' completedOnboarding: $completedOnboarding, bypassesVerification: $bypassesVerification, startedOnBoarding: $startedOnBoarding)';
}
