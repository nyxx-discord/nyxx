part of nyxx;

/// Set of permissions ints
class _PermissionsSet {
  int allow = 0;
  int deny = 0;

  Map<String, dynamic> _build() => {"allow": allow, "deny": deny};
}

/// Builder for permissions.
class PermissionsBuilder extends AbstractPermissions {
  _PermissionsSet _build() {
    var tmp = _PermissionsSet();

    _apply(tmp, this.createInstantInvite,
        PermissionsConstants.createInstantInvite);
    _apply(tmp, this.kickMembers, PermissionsConstants.kickMembers);
    _apply(tmp, this.banMembers, PermissionsConstants.banMembers);
    _apply(tmp, this.administrator, PermissionsConstants.administrator);
    _apply(tmp, this.manageChannels, PermissionsConstants.manageChannels);
    _apply(tmp, this.addReactions, PermissionsConstants.addReactions);
    _apply(tmp, this.viewAuditLog, PermissionsConstants.viewAuditLog);
    _apply(tmp, this.viewChannel, PermissionsConstants.viewChannel);
    _apply(tmp, this.manageGuild, PermissionsConstants.manageGuild);
    _apply(tmp, this.sendMessages, PermissionsConstants.sendMessages);
    _apply(tmp, this.sendTtsMessages, PermissionsConstants.sendTtsMessages);
    _apply(tmp, this.manageMessages, PermissionsConstants.manageMessages);
    _apply(tmp, this.embedLinks, PermissionsConstants.embedLinks);
    _apply(tmp, this.attachFiles, PermissionsConstants.attachFiles);
    _apply(tmp, this.readMessageHistory,
        PermissionsConstants.readMessageHistory);
    _apply(tmp, this.mentionEveryone, PermissionsConstants.mentionEveryone);
    _apply(tmp, this.useExternalEmojis, PermissionsConstants.externalEmojis);
    _apply(tmp, this.connect, PermissionsConstants.connect);
    _apply(tmp, this.speak, PermissionsConstants.speak);
    _apply(tmp, this.muteMembers, PermissionsConstants.muteMembers);
    _apply(tmp, this.deafenMembers, PermissionsConstants.deafenMembers);
    _apply(tmp, this.moveMembers, PermissionsConstants.moveMembers);
    _apply(tmp, this.useVad, PermissionsConstants.useVad);
    _apply(tmp, this.changeNickname, PermissionsConstants.changeNickname);
    _apply(tmp, this.manageNicknames, PermissionsConstants.manageNicknames);
    _apply(tmp, this.manageRoles,
        PermissionsConstants.manageRolesOrPermissions);
    _apply(tmp, this.manageWebhooks, PermissionsConstants.manageWebhooks);

    return tmp;
  }

  void _apply(_PermissionsSet perm, bool canApply, int constant) {
    if (canApply == null) return;

    if (canApply)
      perm.allow |= constant;
    else
      perm.deny |= constant;
  }
}
