part of nyxx;

/// Permissions for a role or channel override.
class Permissions extends AbstractPermissions {
  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    _construct(permissions);
  }

  /// Makes a [Permissions] object from overwrite object
  Permissions.fromOverwrite(int permissions, int allow, int deny) {
    int applied = permissions & ~deny;
    applied |= allow;

    _construct(applied);
  }

  void _construct(int permissions) {
    this.raw = permissions;
    this.createInstantInvite =
        (this.raw & PermissionsConstants.createInstantInvite) > 0;
    this.kickMembers = (this.raw & PermissionsConstants.kickMembers) > 0;
    this.banMembers = (this.raw & PermissionsConstants.banMembers) > 0;
    this.administrator = (this.raw & PermissionsConstants.administrator) > 0;
    this.manageChannels = (this.raw & PermissionsConstants.manageChannels) > 0;
    this.manageGuild = (this.raw & PermissionsConstants.manageGuild) > 0;
    this.addReactions = (this.raw & PermissionsConstants.addReactions) > 0;
    this.viewAuditLog = (this.raw & PermissionsConstants.viewAuditLog) > 0;
    this.viewChannel = (this.raw & PermissionsConstants.viewChannel) > 0;
    this.sendMessages = (this.raw & PermissionsConstants.sendMessages) > 0;
    this.prioritySpeaker =
        (this.raw & PermissionsConstants.prioritySpeaker) > 0;
    this.sendTtsMessages =
        (this.raw & PermissionsConstants.sendTtsMessages) > 0;
    this.manageMessages = (this.raw & PermissionsConstants.manageMessages) > 0;
    this.embedLinks = (this.raw & PermissionsConstants.embedLinks) > 0;
    this.attachFiles = (this.raw & PermissionsConstants.attachFiles) > 0;
    this.readMessageHistory =
        (this.raw & PermissionsConstants.readMessageHistory) > 0;
    this.mentionEveryone =
        (this.raw & PermissionsConstants.mentionEveryone) > 0;
    this.useExternalEmojis =
        (this.raw & PermissionsConstants.externalEmojis) > 0;
    this.connect = (this.raw & PermissionsConstants.connect) > 0;
    this.speak = (this.raw & PermissionsConstants.speak) > 0;
    this.muteMembers = (this.raw & PermissionsConstants.muteMembers) > 0;
    this.deafenMembers = (this.raw & PermissionsConstants.deafenMembers) > 0;
    this.moveMembers = (this.raw & PermissionsConstants.moveMembers) > 0;
    this.useVad = (this.raw & PermissionsConstants.useVad) > 0;
    this.changeNickname = (this.raw & PermissionsConstants.changeNickname) > 0;
    this.manageNicknames =
        (this.raw & PermissionsConstants.manageNicknames) > 0;
    this.manageRoles =
        (this.raw & PermissionsConstants.manageRolesOrPermissions) > 0;
    this.manageWebhooks = (this.raw & PermissionsConstants.manageWebhooks) > 0;
  }
}
