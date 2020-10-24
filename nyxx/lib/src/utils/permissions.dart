part of nyxx;

/// Util function for manipulating permissions
class PermissionsUtils {
  /// Allows to check if [issueMember] or [issueRole] can interact with [targetMember] or [targetRole].
  static bool canInteract({Member? issueMember, RoleNew? issueRole, Member? targetMember, RoleNew? targetRole}) {
    bool canInter(RoleNew role1, RoleNew role2) => role1.position > role2.position;

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
  static List<int> getOverrides(Member member, GuildChannel channel) {
    var allowRaw = 0;
    var denyRaw = 0;

    try {
      final publicOverride = channel.permissionOverrides.firstWhere((ov) => ov.id == member.guild.getFromCache()?.everyoneRole.id);
      allowRaw = publicOverride.allow;
      denyRaw = publicOverride.deny;
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } on Error { }

    var allowRole = 0;
    var denyRole = 0;

    for (final role in member.roles) {
      try {
        final chanOverride = channel.permissionOverrides.firstWhere((f) => f.id == role.id);

        denyRole |= chanOverride.deny;
        allowRole |= chanOverride.allow;
        // ignore: avoid_catches_without_on_clauses, empty_catches
      } on Error { }
    }

    allowRaw = (allowRaw & ~denyRole) | allowRole;
    denyRaw = (denyRaw & ~allowRole) | denyRole;

    // TODO: NNBD: try-catch in where
    try {
      final memberOverride = channel.permissionOverrides.firstWhere((g) => g.id == member.id);

      allowRaw = (allowRaw & ~memberOverride.deny) | memberOverride.allow;
      denyRaw = (denyRaw & ~memberOverride.allow) | memberOverride.deny;
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } on Error { }

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
