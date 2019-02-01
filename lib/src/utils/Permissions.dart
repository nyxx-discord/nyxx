import 'package:nyxx/nyxx.dart';

/// Allows to check if [issueMember] or [issueRole] can interact with [targetMember] or [targetRole].
bool canInteract(
    {Member issueMember,
    Role issueRole,
    Member targetMember,
    Role targetRole}) {
  bool canInter(Role role1, Role role2) => role1.position > role2.position;

  if (issueMember != null && targetMember != null) {
    if (issueMember.guild != targetMember.guild) return false;

    return canInter(issueMember.highestRole, targetMember.highestRole);
  }

  if (issueMember != null && targetRole != null) {
    if (issueMember.guild != targetRole.guild) return false;

    return canInter(issueMember.highestRole, targetRole);
  }

  if (issueRole != null && targetRole != null) {
    if (issueRole.guild != targetRole.guild) return false;

    return canInter(issueRole, targetRole);
  }

  return false;
}

/// Returns List of [channel] permissions overrides for given [member].
List<int> getOverrides(Member member, GuildChannel channel) {
  var allowRaw = 0;
  var denyRaw = 0;

  try {
    var publicOverride = channel.permissions
        .firstWhere((ov) => ov.id == member.guild.everyoneRole.id);
    allowRaw = publicOverride.allow;
    denyRaw = publicOverride.deny;
  } catch (e) {}

  var allowRole = 0;
  var denyRole = 0;

  for (var role in member.roles) {
    var chanOveride = channel.permissions
        .firstWhere((f) => f.id == role.id, orElse: () => null);

    if (chanOveride != null) {
      denyRole |= chanOveride.deny;
      allowRole |= chanOveride.allow;
    }
  }

  allowRaw = (allowRaw & ~denyRole) | allowRole;
  denyRaw = (denyRaw & ~allowRole) | denyRole;

  final memberOverride = channel.permissions
      .firstWhere((g) => g.id == member.id, orElse: () => null);

  if (memberOverride != null) {
    final oDeny = memberOverride.deny;
    final oAllow = memberOverride.allow;
    allowRaw = (allowRaw & ~oDeny) | oAllow;
    denyRaw = (denyRaw & ~oAllow) | oDeny;
  }

  return [allowRaw, denyRaw];
}

/// Apply [deny] and [allow] to [permissions].
int apply(int permissions, int allow, int deny) {
  permissions &= ~deny;
  permissions |= allow;

  return permissions;
}

/// Returns true if [permission] is applied to [permissions].
bool isApplied(int permissions, int permission) =>
    (permissions & permission) == permission;
