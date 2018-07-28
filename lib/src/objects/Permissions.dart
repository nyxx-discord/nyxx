part of nyxx;

/// Permissions for a role or channel override.
class Permissions {
  /// The raw permission code.
  int raw;

  /// True if user can craete InstantInvite
  bool createInstantInvite;

  /// True if user can kick members
  bool kickMembers;

  /// True if user can ban members
  bool banMembers;

  /// True if user is administrator
  bool administrator;

  /// True if user can mamanger channels
  bool manageChannels;

  /// True if user can manager guilds
  bool manageGuild;

  /// Allows to add reactions
  bool addReactions;

  /// Allow to view audit logs
  bool viewAuditLog;

  /// Allow viewing channels
  bool viewChannel;

  /// True if user can send messages
  bool sendMessages;

  /// True if user can send TTF messages
  bool sendTtsMessages;

  /// True if user can manage messages
  bool manageMessages;

  /// True if user can send links in messages
  bool embedLinks;

  /// True if user can attach files in messages
  bool attachFiles;

  /// True if user can read messages history
  bool readMessageHistory;

  /// True if user can mention everyone
  bool mentionEveryone;

  /// True if user can use external emojis
  bool useExternalEmojis;

  /// True if user can connect to voice channel
  bool connect;

  /// True if user can speak
  bool speak;

  /// True if user can mute members
  bool muteMembers;

  /// True if user can deafen members
  bool deafenMembers;

  /// True if user can move members
  bool moveMembers;

  /// Allows for using voice-activity-detection in a voice channel
  bool useVad;

  /// True if user can change nick
  bool changeNickname;

  /// True if user can manager others nicknames
  bool manageNicknames;

  /// True if user can manage server's roles
  bool manageRoles;

  /// True if user can manage webhooks
  bool manageWebhooks;

  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    _construct(permissions);
  }

  Permissions.fromOverwrite(int permissions, int overwrite) {
    int applied = permissions | overwrite;

    _construct(applied);
  }

  void _construct(int permissions) {
    this.raw = permissions;
    this.createInstantInvite =
        (this.raw & PermissionsConstants.CREATE_INSTANT_INVITE) > 0;
    this.kickMembers = (this.raw & PermissionsConstants.KICK_MEMBERS) > 0;
    this.banMembers = (this.raw & PermissionsConstants.BAN_MEMBERS) > 0;
    this.administrator =
        (this.raw & PermissionsConstants.ADMINISTRATOR) > 0;
    this.manageChannels =
        (this.raw & PermissionsConstants.MANAGE_CHANNELS) > 0;
    this.manageGuild = (this.raw & PermissionsConstants.MANAGE_GUILD) > 0;
    this.addReactions =
        (this.raw & PermissionsConstants.ADD_REACTIONS) > 0;
    this.viewAuditLog =
        (this.raw & PermissionsConstants.VIEW_AUDIT_LOG) > 0;
    this.viewChannel =
        (this.raw & PermissionsConstants.VIEW_CHANNEL) > 0;
    this.sendMessages =
        (this.raw & PermissionsConstants.SEND_MESSAGES) > 0;
    this.sendTtsMessages =
        (this.raw & PermissionsConstants.SEND_TTS_MESSAGES) > 0;
    this.manageMessages =
        (this.raw & PermissionsConstants.MANAGE_MESSAGES) > 0;
    this.embedLinks = (this.raw & PermissionsConstants.EMBED_LINKS) > 0;
    this.attachFiles = (this.raw & PermissionsConstants.ATTACH_FILES) > 0;
    this.readMessageHistory =
        (this.raw & PermissionsConstants.READ_MESSAGE_HISTORY) > 0;
    this.mentionEveryone =
        (this.raw & PermissionsConstants.MENTION_EVERYONE) > 0;
    this.useExternalEmojis =
        (this.raw & PermissionsConstants.EXTERNAL_EMOJIS) > 0;
    this.connect = (this.raw & PermissionsConstants.CONNECT) > 0;
    this.speak = (this.raw & PermissionsConstants.SPEAK) > 0;
    this.muteMembers = (this.raw & PermissionsConstants.MUTE_MEMBERS) > 0;
    this.deafenMembers =
        (this.raw & PermissionsConstants.DEAFEN_MEMBERS) > 0;
    this.moveMembers = (this.raw & PermissionsConstants.MOVE_MEMBERS) > 0;
    this.useVad = (this.raw & PermissionsConstants.USE_VAD) > 0;
    this.changeNickname =
        (this.raw & PermissionsConstants.CHANGE_NICKNAME) > 0;
    this.manageNicknames =
        (this.raw & PermissionsConstants.MANAGE_NICKNAMES) > 0;
    this.manageRoles =
        (this.raw & PermissionsConstants.MANAGE_ROLES_OR_PERMISSIONS) > 0;
    this.manageWebhooks =
        (this.raw & PermissionsConstants.MANAGE_WEBHOOKS) > 0;
  }
}
