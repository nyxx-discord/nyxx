import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/utils/utils.dart';

/// Util function for manipulating permissions
class PermissionsUtils {
  /// Allows to check if [issueMember] or [issueRole] can interact with [targetMember] or [targetRole].
  static bool canInteract({IMember? issueMember, IRole? issueRole, IMember? targetMember, IRole? targetRole}) {
    bool canInter(IRole role1, IRole role2) => role1.position > role2.position;

    if (issueMember != null && targetMember != null) {
      if (issueMember.guild != targetMember.guild) {
        return false;
      }

      return canInter(issueMember.highestRole, targetMember.highestRole);
    }

    if (issueMember != null && targetRole != null) {
      if (issueMember.guild != targetRole.guild) {
        return false;
      }

      return canInter(issueMember.highestRole, targetRole);
    }

    if (issueRole != null && targetRole != null) {
      if (issueRole.guild != targetRole.guild) return false;

      return canInter(issueRole, targetRole);
    }

    return false;
  }

  /// Returns List of [channel] permissions overrides for given [member].
  static List<int> getOverrides(IMember member, IGuildChannel channel) {
    var allowRaw = 0;
    var denyRaw = 0;

    final publicOverride = channel.permissionOverrides.firstWhereSafe((ov) => ov.id == member.guild.getFromCache()?.everyoneRole.id);

    if (publicOverride != null) {
      allowRaw = publicOverride.allow;
      denyRaw = publicOverride.deny;
    }

    var allowRole = 0;
    var denyRole = 0;

    for (final role in member.roles) {
      final channelOverride = channel.permissionOverrides.firstWhereSafe((f) => f.id == role.id);

      if (channelOverride != null) {
        denyRole |= channelOverride.deny;
        allowRole |= channelOverride.allow;
      }
    }

    allowRaw = (allowRaw & ~denyRole) | allowRole;
    denyRaw = (denyRaw & ~allowRole) | denyRole;

    final memberOverride = channel.permissionOverrides.firstWhereSafe((g) => g.id == member.id);

    if (memberOverride != null) {
      allowRaw = (allowRaw & ~memberOverride.deny) | memberOverride.allow;
      denyRaw = (denyRaw & ~memberOverride.allow) | memberOverride.deny;
    }

    return [allowRaw, denyRaw];
  }

  /// Apply [deny] and [allow] to [permissions].
  static int apply(int permissions, int allow, int deny) {
    permissions &= ~deny;
    permissions |= allow;

    return permissions;
  }

  /// Returns true if [permission] is applied to [permissions].
  static bool isApplied(int permissions, int permission) => (permissions & permission) == permission;
}
