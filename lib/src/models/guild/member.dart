import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialMember extends SnowflakeEntity<Member> with SnowflakeEntityMixin<Member> {
  @override
  final MemberManager manager;

  PartialMember({required super.id, required this.manager});

  Future<void> addRole(Snowflake roleId, {String? auditLogReason}) => manager.addRole(id, roleId, auditLogReason: auditLogReason);

  Future<void> removeRole(Snowflake roleId, {String? auditLogReason}) => manager.removeRole(id, roleId);

  Future<void> ban({String? auditLogReason}) => manager.client.guilds[manager.guildId].createBan(id, auditLogReason: auditLogReason);

  Future<void> unban({String? auditLogReason}) => manager.client.guilds[manager.guildId].deleteBan(id, auditLogReason: auditLogReason);
}

class Member extends PartialMember {
  final User? user;

  final String? nick;

  final String? avatarHash;

  final List<Snowflake> roleIds;

  final DateTime joinedAt;

  final DateTime? premiumSince;

  final bool isDeaf;

  final bool isMute;

  final MemberFlags flags;

  final bool isPending;

  final Permissions? permissions;

  final DateTime? communicationDisabledUntil;

  Member({
    required super.id,
    required super.manager,
    required this.user,
    required this.nick,
    required this.avatarHash,
    required this.roleIds,
    required this.joinedAt,
    required this.premiumSince,
    required this.isDeaf,
    required this.isMute,
    required this.flags,
    required this.isPending,
    required this.permissions,
    required this.communicationDisabledUntil,
  });
}

class MemberFlags extends Flags<MemberFlags> {
  static const didRejoin = Flag<MemberFlags>.fromOffset(0);
  static const completedOnboarding = Flag<MemberFlags>.fromOffset(1);
  static const bypassesVerification = Flag<MemberFlags>.fromOffset(2);
  static const startedOnboarding = Flag<MemberFlags>.fromOffset(3);

  bool get hasRejoined => has(didRejoin);
  bool get didCompleteOnboarding => has(completedOnboarding);
  bool get hasBypassVerification => has(bypassesVerification);
  bool get didStartOnboarding => has(startedOnboarding);

  const MemberFlags(super.value);
}
