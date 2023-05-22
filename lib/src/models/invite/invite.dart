import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';


/// An invite to a [Guild] or [Channel].
/// If the invite is to a [Channel], this will be a [ChannelType.groupDm] channel.
class Invite with ToStringHelper {
  /// The invite's code. This is a unique identifier.
  final String code;

  /// The [Guild] this invite is for.
  // TODO
  final Object? /*Guild?*/ guild;

  /// The [PartialChannel] this invite is for.
  // TODO
  final PartialChannel channel;

  /// The [User] who created this invite.
  final User? inviter;

  /// The [TargetType] for this voice channel invite.
  final TargetType? targetType;

  /// The [User] whose stream to display for this voice channel stream invite.
  final User? targetUser;

  /// The [PartialApplication] to open for this voice channel embedded application invite.
  // TODO
  final PartialApplication? targetApplication;

  /// The approximate count of members in the [Guild] this invite is for.
  /// {@template invite_approximate_member_count}
  /// This is only available when [InviteManager.fetch] is called with `withCounts` set to `true`.
  /// {@endtemplate}
  final int? approximateMemberCount;

  /// The approximate count of online members in the [Guild] this invite is for.
  /// {@macro invite_approximate_member_count}
  final int? approximatePresenceCount;

  /// The expiration date of this invite.
  /// This is only available when [InviteManager.fetch] is called with `withExpiration` set to `true`.
  final DateTime? expiresAt;

  /// The [GuildScheduledEvent] data, only included if [InviteManager.fetch] is called with `guildScheduledEvent` is set to a valid [Snowflake].
  // TODO
  final Object? /*GuildScheduledEvent?*/ guildScheduledEvent;

  Invite({
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

enum TargetType {
  /// The invite is targeting a stream.
  stream._(1),

  /// The invite is targeting an embedded application.
  embeddedApplication._(2);

  final int value;

  factory TargetType.parse(int value) => TargetType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown TargetType', value),
      );

  const TargetType._(this.value);

  @override
  String toString() => 'TargetType($value)';
}
