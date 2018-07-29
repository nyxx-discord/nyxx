part of nyxx;

/// Set of permissions ints
class PermissionsSet {
  int allow = 0;
  int deny = 0;

  Map<String, dynamic> _build() => { "allow" : allow, "deny": deny };
}

/// Builder for permissions.
class PermissionsBuilder extends AbstractPermissions {
  PermissionsSet _build() {
    var tmp = new PermissionsSet();

    _apply(tmp, this.createInstantInvite, PermissionsConstants.CREATE_INSTANT_INVITE);
    _apply(tmp, this.kickMembers, PermissionsConstants.KICK_MEMBERS);
    _apply(tmp, this.banMembers, PermissionsConstants.BAN_MEMBERS);
    _apply(tmp, this.administrator,  PermissionsConstants.ADMINISTRATOR);
    _apply(tmp, this.manageChannels,  PermissionsConstants.MANAGE_CHANNELS);
    _apply(tmp, this.addReactions, PermissionsConstants.ADD_REACTIONS);
    _apply(tmp, this.viewAuditLog, PermissionsConstants.VIEW_AUDIT_LOG);
    _apply(tmp, this.viewChannel, PermissionsConstants.VIEW_CHANNEL);
    _apply(tmp, this.manageGuild, PermissionsConstants.MANAGE_GUILD);
    _apply(tmp, this.sendMessages,  PermissionsConstants.SEND_MESSAGES);
    _apply(tmp, this.sendTtsMessages,  PermissionsConstants.SEND_TTS_MESSAGES);
    _apply(tmp, this.manageMessages,  PermissionsConstants.MANAGE_MESSAGES);
    _apply(tmp, this.embedLinks, PermissionsConstants.EMBED_LINKS);
    _apply(tmp, this.attachFiles, PermissionsConstants.ATTACH_FILES);
    _apply(tmp, this.readMessageHistory,  PermissionsConstants.READ_MESSAGE_HISTORY);
    _apply(tmp, this.mentionEveryone,  PermissionsConstants.MENTION_EVERYONE);
    _apply(tmp, this.useExternalEmojis,  PermissionsConstants.EXTERNAL_EMOJIS);
    _apply(tmp, this.connect, PermissionsConstants.CONNECT);
    _apply(tmp, this.speak, PermissionsConstants.SPEAK);
    _apply(tmp, this.muteMembers, PermissionsConstants.MUTE_MEMBERS);
    _apply(tmp, this.deafenMembers,  PermissionsConstants.DEAFEN_MEMBERS);
    _apply(tmp, this.moveMembers, PermissionsConstants.MOVE_MEMBERS);
    _apply(tmp, this.useVad, PermissionsConstants.USE_VAD);
    _apply(tmp, this.changeNickname,  PermissionsConstants.CHANGE_NICKNAME);
    _apply(tmp, this.manageNicknames,  PermissionsConstants.MANAGE_NICKNAMES);
    _apply(tmp, this.manageRoles,  PermissionsConstants.MANAGE_ROLES_OR_PERMISSIONS);
    _apply(tmp, this.manageWebhooks, PermissionsConstants.MANAGE_WEBHOOKS);

    print(tmp.allow);
    print(tmp.deny);

    return tmp;
  }

  void _apply(PermissionsSet perm, bool canApply, int constant) {
    if(canApply == null)
      return;

    if(canApply)
      perm.allow |= constant;
    else
      perm.deny |= constant;
  }
}