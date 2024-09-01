import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template invite}
/// An invite to a [Guild] or [Channel].
/// If the invite is to a [Channel], this will be a [GroupDmChannel].
/// {@endtemplate}
class Invite with ToStringHelper {
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

  /// {@macro invite}
  /// @nodoc
  Invite({
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
  });
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
