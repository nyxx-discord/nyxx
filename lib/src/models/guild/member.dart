import 'package:nyxx/src/builders/guild/member.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/avatar_decoration_data.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A partial [Member].
class PartialMember extends WritableSnowflakeEntity<Member> {
  @override
  final MemberManager manager;

  /// Create a new [PartialMember].
  /// @nodoc
  PartialMember({required super.id, required this.manager});

  /// Add a role to this member.
  Future<void> addRole(Snowflake roleId, {String? auditLogReason}) => manager.addRole(id, roleId, auditLogReason: auditLogReason);

  /// Remove a role from this member.
  Future<void> removeRole(Snowflake roleId, {String? auditLogReason}) => manager.removeRole(id, roleId);

  /// Ban this member.
  Future<void> ban({Duration? deleteMessages, String? auditLogReason}) =>
      manager.client.guilds[manager.guildId].createBan(id, auditLogReason: auditLogReason, deleteMessages: deleteMessages);

  /// Unban this member.
  Future<void> unban({String? auditLogReason}) => manager.client.guilds[manager.guildId].deleteBan(id, auditLogReason: auditLogReason);

  /// Update this member, returning the updated member.
  ///
  /// External references:
  /// * [MemberManager.update]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/guild#modify-guild-member
  @override
  Future<Member> update(MemberUpdateBuilder builder, {String? auditLogReason}) => manager.update(id, builder, auditLogReason: auditLogReason);

  /// Kick this member.
  ///
  /// External references:
  /// * [MemberManager.delete]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/guild#remove-guild-member
  @override
  Future<void> delete({String? auditLogReason}) => manager.delete(id, auditLogReason: auditLogReason);
}

/// {@template member}
/// The representation of a [User] in a [Guild].
/// {@endtemplate}
class Member extends PartialMember {
  /// The [User] this member represents.
  final User? user;

  /// This member's nickname.
  final String? nick;

  /// The hash of this member's avatar image.
  final String? avatarHash;

  /// The hash of this member's banner image.
  final String? bannerHash;

  /// A list of the IDs of the roles this member has.
  final List<Snowflake> roleIds;

  /// The time at which this member joined the guild.
  final DateTime joinedAt;

  /// The time at which this member started boosting the guild.
  final DateTime? premiumSince;

  /// Whether this member is deafened in voice channels.
  final bool? isDeaf;

  /// Whether this member is muted in voice channels.
  final bool? isMute;

  /// A set of flags associated with this member.
  final MemberFlags flags;

  /// Whether this member has not yet passed the guild's membership screening requirements.
  final bool isPending;

  /// In an interaction payload, the computed permissions of this member in the current channel.
  final Permissions? permissions;

  /// The time until which this member is timed out.
  final DateTime? communicationDisabledUntil;

  /// The member's guild avatar decoration data.
  final AvatarDecorationData? avatarDecorationData;

  /// The member's guild avatar decoration.
  final String? avatarDecorationHash;

  /// {@macro member}
  /// @nodoc
  Member({
    required super.id,
    required super.manager,
    required this.user,
    required this.nick,
    required this.avatarHash,
    required this.bannerHash,
    required this.roleIds,
    required this.joinedAt,
    required this.premiumSince,
    required this.isDeaf,
    required this.isMute,
    required this.flags,
    required this.isPending,
    required this.permissions,
    required this.communicationDisabledUntil,
    required this.avatarDecorationData,
    required this.avatarDecorationHash,
  });

  /// The roles this member has.
  List<PartialRole> get roles => roleIds.map((e) => manager.client.guilds[manager.guildId].roles[e]).toList();

  /// This member's avatar.
  CdnAsset? get avatar => avatarHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()
            ..guilds(id: manager.guildId.toString())
            ..users(id: id.toString())
            ..avatars(),
          hash: avatarHash!,
        );

  CdnAsset? get avatarDecoration => avatarDecorationHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..avatarDecorationPresets(),
          hash: avatarDecorationHash!,
        );

  CdnAsset? get banner => bannerHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()
            ..guilds(id: manager.guildId.toString())
            ..users(id: id.toString())
            ..banners(),
          hash: bannerHash!,
        );
}

/// Flags that can be applied to a [Member].
class MemberFlags extends Flags<MemberFlags> {
  /// This member has left and rejoined the guild.
  static const didRejoin = Flag<MemberFlags>.fromOffset(0);

  /// This member completed the guild's onboarding process.
  static const completedOnboarding = Flag<MemberFlags>.fromOffset(1);

  /// This member is exempt from guild verification requirements.
  static const bypassesVerification = Flag<MemberFlags>.fromOffset(2);

  /// This member has started the guild's onboarding process.
  static const startedOnboarding = Flag<MemberFlags>.fromOffset(3);

  /// Member is a guest and can only access the voice channel they were invited to.
  static const isGuest = Flag<MemberFlags>.fromOffset(4);

  /// Member has started Server Guide new member actions.
  static const startedHomeActions = Flag<MemberFlags>.fromOffset(5);

  /// Member has completed Server Guide new member actions.
  static const completedHomeActions = Flag<MemberFlags>.fromOffset(6);

  /// Member's username, display name, or nickname is blocked by AutoMod.
  static const automodQuarantinedUsername = Flag<MemberFlags>.fromOffset(7);

  // 1 << 8 is AUTOMOD_QUARANTINED_BIO but it's undocumented and deprecated

  /// Member has dismissed the DM settings upsell
  static const dmSettingsUpsellAcknowledged = Flag<MemberFlags>.fromOffset(9);

  /// Whether this member has the [didRejoin] flag.
  bool get hasRejoined => has(didRejoin);

  /// Whether this member has the [completedOnboarding] flag.
  bool get didCompleteOnboarding => has(completedOnboarding);

  /// Whether this member has the [bypassesVerification] flag.
  bool get hasBypassVerification => has(bypassesVerification);

  /// Whether this member has the [startedOnboarding] flag.
  bool get didStartOnboarding => has(startedOnboarding);

  /// Whether this member has the [isGuest] flag.
  bool get isGuestMember => has(isGuest);

  /// Whether this member has the [startedHomeActions] flag.
  bool get didStartHomeActions => has(startedHomeActions);

  /// Whether this member has the [completedHomeActions] flag.
  bool get didCompleteHomeActions => has(completedHomeActions);

  /// Whether this member has the [automodQuarantinedUsername] flag.
  bool get hasAutomodQuarantinedUsername => has(automodQuarantinedUsername);

  /// Whether this member has the [dmSettingsUpsellAcknowledged] flag.
  bool get didAcknowledgeDmSettingsUpsell => has(dmSettingsUpsellAcknowledged);

  /// Create a new [MemberFlags].
  const MemberFlags(super.value);
}
