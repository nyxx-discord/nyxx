part of nyxx;

/// Permissions for a role or channel override.
class Permissions extends AbstractPermissions {
  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    _construct(permissions);
  }

  Permissions.empty() {
    _construct(0);
  }

  Permissions.all() {
    _construct(PermissionsConstants.allPermissions);
  }

  /// Makes a [Permissions] object from overwrite object
  Permissions.fromOverwrite(int permissions, int allow, int deny) {
    _construct(utils.apply(permissions, allow, deny));
  }

  void _construct(int permissions) {
    this.raw = permissions;

    this.createInstantInvite = utils.isApplied(permissions, PermissionsConstants.createInstantInvite);
    this.kickMembers = utils.isApplied(permissions, PermissionsConstants.kickMembers);
    this.banMembers = utils.isApplied(permissions, PermissionsConstants.banMembers);
    this.administrator = utils.isApplied(permissions, PermissionsConstants.administrator);
    this.manageChannels = utils.isApplied(permissions, PermissionsConstants.manageChannels);
    this.manageGuild = utils.isApplied(permissions, PermissionsConstants.manageGuild);
    this.addReactions = utils.isApplied(permissions, PermissionsConstants.addReactions);
    this.viewAuditLog = utils.isApplied(permissions, PermissionsConstants.viewAuditLog);
    this.viewChannel = utils.isApplied(permissions, PermissionsConstants.viewChannel);
    this.sendMessages = utils.isApplied(permissions, PermissionsConstants.sendMessages);
    this.prioritySpeaker = utils.isApplied(permissions, PermissionsConstants.prioritySpeaker);
    this.sendTtsMessages = utils.isApplied(permissions, PermissionsConstants.sendTtsMessages);
    this.manageMessages = utils.isApplied(permissions, PermissionsConstants.manageMessages);
    this.embedLinks = utils.isApplied(permissions, PermissionsConstants.embedLinks);
    this.attachFiles = utils.isApplied(permissions, PermissionsConstants.attachFiles);
    this.readMessageHistory = utils.isApplied(permissions, PermissionsConstants.readMessageHistory);
    this.mentionEveryone = utils.isApplied(permissions, PermissionsConstants.mentionEveryone);
    this.useExternalEmojis = utils.isApplied(permissions, PermissionsConstants.externalEmojis);
    this.connect = utils.isApplied(permissions, PermissionsConstants.connect);
    this.speak = utils.isApplied(permissions, PermissionsConstants.speak);
    this.muteMembers = utils.isApplied(permissions, PermissionsConstants.muteMembers);
    this.deafenMembers = utils.isApplied(permissions, PermissionsConstants.deafenMembers);
    this.moveMembers = utils.isApplied(permissions, PermissionsConstants.moveMembers);
    this.useVad = utils.isApplied(permissions, PermissionsConstants.useVad);
    this.changeNickname = utils.isApplied(permissions, PermissionsConstants.changeNickname);
    this.manageNicknames = utils.isApplied(permissions, PermissionsConstants.manageNicknames);
    this.manageRoles = utils.isApplied(permissions, PermissionsConstants.manageRolesOrPermissions);
    this.manageWebhooks = utils.isApplied(permissions, PermissionsConstants.manageWebhooks);
  }
}
