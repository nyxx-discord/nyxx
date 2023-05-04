import 'invite.dart';

class InviteMetadata extends Invite {
  /// The number of times this invite has been used.
  final int uses;

  /// The max number of times this invite can be used.
  final int maxUses;

  /// The duration (in seconds) after which the invite expires.
  final int maxAge;

  /// Whether this invite only grants temporary membership.
  final bool isTemporary;

  /// When this invite was created.
  final DateTime createdAt;

  InviteMetadata({
    required super.code,
    required super.guild,
    // required super.channel,
    super.inviter,
    super.targetType,
    super.targetUser,
    super.targetApplication,
    super.approximateMemberCount,
    super.approximatePresenceCount,
    super.expiresAt,
    super.stageInstance,
    super.guildScheduledEvent,
    required this.uses,
    required this.maxUses,
    required this.maxAge,
    required this.isTemporary,
    required this.createdAt,
  });
}
