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

    _apply(tmp, this.createInstantInvite, _Constants.permissions['CREATE_INSTANT_INVITE']);
    _apply(tmp, this.kickMembers, _Constants.permissions['KICK_MEMBERS']);
    _apply(tmp, this.banMembers, _Constants.permissions['BAN_MEMBERS']);
    _apply(tmp, this.administrator,  _Constants.permissions['ADMINISTRATOR']);
    _apply(tmp, this.manageChannels,  _Constants.permissions['MANAGE_CHANNELS']);
    _apply(tmp, this.manageGuild, _Constants.permissions['MANAGE_GUILD']);
    _apply(tmp, this.readMessages,  _Constants.permissions['READ_MESSAGES']);
    _apply(tmp, this.sendMessages,  _Constants.permissions['SEND_MESSAGES']);
    _apply(tmp, this.sendTtsMessages,  _Constants.permissions['SEND_TTS_MESSAGES']);
    _apply(tmp, this.manageMessages,  _Constants.permissions['MANAGE_MESSAGES']);
    _apply(tmp, this.embedLinks, _Constants.permissions['EMBED_LINKS']);
    _apply(tmp, this.attachFiles, _Constants.permissions['ATTACH_FILES']);
    _apply(tmp, this.readMessageHistory,  _Constants.permissions['READ_MESSAGE_HISTORY']);
    _apply(tmp, this.mentionEveryone,  _Constants.permissions['MENTION_EVERYONE']);
    _apply(tmp, this.useExternalEmojis,  _Constants.permissions['EXTERNAL_EMOJIS']);
    _apply(tmp, this.connect, _Constants.permissions['CONNECT']);
    _apply(tmp, this.speak, _Constants.permissions['SPEAK']);
    _apply(tmp, this.muteMembers, _Constants.permissions['MUTE_MEMBERS']);
    _apply(tmp, this.deafenMembers,  _Constants.permissions['DEAFEN_MEMBERS']);
    _apply(tmp, this.moveMembers, _Constants.permissions['MOVE_MEMBERS']);
    _apply(tmp, this.useVad, _Constants.permissions['USE_VAD']);
    _apply(tmp, this.changeNickname,  _Constants.permissions['CHANGE_NICKNAME']);
    _apply(tmp, this.manageNicknames,  _Constants.permissions['MANAGE_NICKNAMES']);
    _apply(tmp, this.manageRoles,  _Constants.permissions['MANAGE_ROLES_OR_PERMISSIONS']);
    _apply(tmp, this.manageWebhooks, _Constants.permissions['MANAGE_WEBHOOKS']);

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