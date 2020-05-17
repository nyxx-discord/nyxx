part of nyxx;

/// Permissions for a role or channel override.
class Permissions extends AbstractPermissions {
  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    _construct(permissions);
  }

  /// Permissions with value of 0
  Permissions.empty() {
    _construct(0);
  }

  /// Permissions with max value
  Permissions.all() {
    _construct(PermissionsConstants.allPermissions);
  }

  /// Makes a [Permissions] object from overwrite object
  Permissions.fromOverwrite(int permissions, int allow, int deny) {
    _construct(PermissionsUtils.apply(permissions, allow, deny));
  }

  void _construct(int permissions) {
    this.raw = permissions;

    this.createInstantInvite = PermissionsUtils.isApplied(permissions, PermissionsConstants.createInstantInvite);
    this.kickMembers = PermissionsUtils.isApplied(permissions, PermissionsConstants.kickMembers);
    this.banMembers = PermissionsUtils.isApplied(permissions, PermissionsConstants.banMembers);
    this.administrator = PermissionsUtils.isApplied(permissions, PermissionsConstants.administrator);
    this.manageChannels = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageChannels);
    this.manageGuild = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageGuild);
    this.addReactions = PermissionsUtils.isApplied(permissions, PermissionsConstants.addReactions);
    this.viewAuditLog = PermissionsUtils.isApplied(permissions, PermissionsConstants.viewAuditLog);
    this.viewChannel = PermissionsUtils.isApplied(permissions, PermissionsConstants.viewChannel);
    this.sendMessages = PermissionsUtils.isApplied(permissions, PermissionsConstants.sendMessages);
    this.prioritySpeaker = PermissionsUtils.isApplied(permissions, PermissionsConstants.prioritySpeaker);
    this.sendTtsMessages = PermissionsUtils.isApplied(permissions, PermissionsConstants.sendTtsMessages);
    this.manageMessages = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageMessages);
    this.embedLinks = PermissionsUtils.isApplied(permissions, PermissionsConstants.embedLinks);
    this.attachFiles = PermissionsUtils.isApplied(permissions, PermissionsConstants.attachFiles);
    this.readMessageHistory = PermissionsUtils.isApplied(permissions, PermissionsConstants.readMessageHistory);
    this.mentionEveryone = PermissionsUtils.isApplied(permissions, PermissionsConstants.mentionEveryone);
    this.useExternalEmojis = PermissionsUtils.isApplied(permissions, PermissionsConstants.externalEmojis);
    this.connect = PermissionsUtils.isApplied(permissions, PermissionsConstants.connect);
    this.speak = PermissionsUtils.isApplied(permissions, PermissionsConstants.speak);
    this.muteMembers = PermissionsUtils.isApplied(permissions, PermissionsConstants.muteMembers);
    this.deafenMembers = PermissionsUtils.isApplied(permissions, PermissionsConstants.deafenMembers);
    this.moveMembers = PermissionsUtils.isApplied(permissions, PermissionsConstants.moveMembers);
    this.useVad = PermissionsUtils.isApplied(permissions, PermissionsConstants.useVad);
    this.changeNickname = PermissionsUtils.isApplied(permissions, PermissionsConstants.changeNickname);
    this.manageNicknames = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageNicknames);
    this.manageRoles = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageRolesOrPermissions);
    this.manageWebhooks = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageWebhooks);

    this.manageEmojis = PermissionsUtils.isApplied(permissions, PermissionsConstants.manageEmojis);
    this.stream = PermissionsUtils.isApplied(permissions, PermissionsConstants.stream);
    this.viewGuildInsights = PermissionsUtils.isApplied(permissions, PermissionsConstants.viewGuildInsights);
  }

  /// Returns true if this permissions has [permission]
  bool hasPermission(int permission) => PermissionsUtils.isApplied(this.raw, permission);

  @override
  int get hashCode => raw.hashCode;

  @override
  bool operator ==(other) {
    if (other is Permissions) return other.raw == this.raw;
    if (other is int) return other == this.raw;

    return false;
  }
}
