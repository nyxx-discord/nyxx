import 'package:nyxx/src/http/managers/invite_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/invite/job_status.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template invite}
/// An invite to a [Guild] or [Channel].
/// If the invite is to a [Channel], this will be a [GroupDmChannel].
/// {@endtemplate}
///
/// {@category models}
class Invite with ToStringHelper {
  /// The manager for this [Invite].
  final InviteManager manager;

  /// The type of this invite.
  final InviteType type;

  /// The invite's code. This is a unique identifier.
  final String code;

  /// The [Guild] this invite is for.
  final PartialGuild? guild;

  /// The [PartialChannel] this invite is for.
  final PartialChannel channel;

  /// The [User] who created this invite.
  final User? inviter;

  /// The [TargetType] for this voice channel invite.
  final TargetType? targetType;

  /// The [User] whose stream to display for this voice channel stream invite.
  final User? targetUser;

  /// The [PartialApplication] to open for this voice channel embedded application invite.
  final PartialApplication? targetApplication;

  /// The approximate count of members in the [Guild] this invite is for.
  ///
  /// {@template invite_approximate_member_count}
  /// This is only available when [InviteManager.fetch] is called with `withCounts` set to `true`.
  /// {@endtemplate}
  final int? approximateMemberCount;

  /// The approximate count of online members in the [Guild] this invite is for.
  ///
  /// {@macro invite_approximate_member_count}
  final int? approximatePresenceCount;

  /// The expiration date of this invite.
  ///
  /// This is only available when [InviteManager.fetch] is called with `withExpiration` set to `true`.
  final DateTime? expiresAt;

  /// The [ScheduledEvent] data, only included if [InviteManager.fetch] is called with `guildScheduledEvent` is set to a valid [Snowflake].
  final ScheduledEvent? guildScheduledEvent;

  /// The flags for this invite.
  final GuildInviteFlags? flags;

  /// The roles assigned to users joining using this invite.
  final List<PartialRole>? roles;

  /// {@macro invite}
  /// @nodoc
  Invite({
    required this.manager,
    required this.type,
    required this.code,
    required this.guild,
    required this.channel,
    required this.inviter,
    required this.targetType,
    required this.targetUser,
    required this.targetApplication,
    required this.approximateMemberCount,
    required this.approximatePresenceCount,
    required this.expiresAt,
    required this.guildScheduledEvent,
    required this.flags,
    required this.roles,
  });

  /// Delete this invite.
  Future<Invite> delete({String? auditLogReason}) => manager.delete(code, auditLogReason: auditLogReason);

  /// Fetch the users this invite is for.
  Future<List<PartialUser>> fetchTargetUsers() => manager.fetchTargetUsers(code);

  /// Update the users targeted by this invite.
  Future<void> updateTargetUsers(List<Snowflake> userIds) => manager.updateTargetUsers(code, userIds);

  /// Fetch the status of processing the target users for this invite.
  Future<InviteTargetsJobStatus> fetchTargetUsersJobStatus() => manager.fetchTargetUsersJobStatus(code);
}

/// The type of an [Invite]'s target.
final class TargetType extends EnumLike<int, TargetType> {
  static const stream = TargetType(1);
  static const embeddedApplication = TargetType(2);

  /// @nodoc
  const TargetType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  TargetType.parse(int value) : this(value);
}

/// The type of an [Invite].
final class InviteType extends EnumLike<int, InviteType> {
  static const guild = InviteType(0);
  static const groupDm = InviteType(1);
  static const friend = InviteType(3);

  /// @nodoc
  const InviteType(super.value);
}

/// Flags for [Invite]s.
class GuildInviteFlags extends Flags<GuildInviteFlags> {
  /// The invite is a guest invite for a voice channel.
  static const isGuestInvite = Flag<GuildInviteFlags>.fromOffset(1 << 0);

  /// Whether this invite is a guest invite for a voice channel.
  bool get hasGuestInvite => has(GuildInviteFlags.isGuestInvite);

  /// @nodoc
  const GuildInviteFlags(super.value);
}
