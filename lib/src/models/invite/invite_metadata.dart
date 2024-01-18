import 'invite.dart';

class InviteWithMetadata extends Invite {
  /// The number of times this invite has been used.
  final int uses;

  /// The max number of times this invite can be used.
  final int maxUses;

  /// The duration after which the invite expires.
  final Duration maxAge;

  /// Whether this invite only grants temporary membership.
  final bool isTemporary;

  /// When this invite was created.
  final DateTime createdAt;

  /// @nodoc
  InviteWithMetadata({
    required super.code,
    required super.guild,
    required super.channel,
    required super.inviter,
    required super.targetType,
    required super.targetUser,
    required super.targetApplication,
    required super.approximateMemberCount,
    required super.approximatePresenceCount,
    required super.expiresAt,
    required super.guildScheduledEvent,
    required this.uses,
    required this.maxUses,
    required this.maxAge,
    required this.isTemporary,
    required this.createdAt,
  });
}
