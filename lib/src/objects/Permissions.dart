part of discord;

/// Permissions for a role or channel override.
class Permissions {
  /// The raw permission code.
  int raw;

  bool createInstantInvite;
  bool kickMembers;
  bool banMembers;
  bool administrator;
  bool manageChannels;
  bool manageGuild;
  bool readMessages;
  bool sendMessages;
  bool sendTtsMessages;
  bool manageMessages;
  bool embedLinks;
  bool attachFiles;
  bool readMessageHistory;
  bool mentionEveryone;
  bool useExternalEmojis;
  bool connect;
  bool speak;
  bool muteMembers;
  bool deafenMembers;
  bool moveMembers;
  bool useVad;
  bool changeNickname;
  bool manageNicknames;
  bool manageRoles;
  bool manageWebhooks;

  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    this.raw = permissions;
    this.createInstantInvite =
        (this.raw & _Constants.permissions['CREATE_INSTANT_INVITE']) > 0;
    this.kickMembers = (this.raw & _Constants.permissions['KICK_MEMBERS']) > 0;
    this.banMembers = (this.raw & _Constants.permissions['BAN_MEMBERS']) > 0;
    this.administrator =
        (this.raw & _Constants.permissions['ADMINISTRATOR']) > 0;
    this.manageChannels =
        (this.raw & _Constants.permissions['MANAGE_CHANNELS']) > 0;
    this.manageGuild = (this.raw & _Constants.permissions['MANAGE_GUILD']) > 0;
    this.readMessages =
        (this.raw & _Constants.permissions['READ_MESSAGES']) > 0;
    this.sendMessages =
        (this.raw & _Constants.permissions['SEND_MESSAGES']) > 0;
    this.sendTtsMessages =
        (this.raw & _Constants.permissions['SEND_TTS_MESSAGES']) > 0;
    this.manageMessages =
        (this.raw & _Constants.permissions['MANAGE_MESSAGES']) > 0;
    this.embedLinks = (this.raw & _Constants.permissions['EMBED_LINKS']) > 0;
    this.attachFiles = (this.raw & _Constants.permissions['ATTACH_FILES']) > 0;
    this.readMessageHistory =
        (this.raw & _Constants.permissions['READ_MESSAGE_HISTORY']) > 0;
    this.mentionEveryone =
        (this.raw & _Constants.permissions['MENTION_EVERYONE']) > 0;
    this.useExternalEmojis =
        (this.raw & _Constants.permissions['EXTERNAL_EMOJIS']) > 0;
    this.connect = (this.raw & _Constants.permissions['CONNECT']) > 0;
    this.speak = (this.raw & _Constants.permissions['SPEAK']) > 0;
    this.muteMembers = (this.raw & _Constants.permissions['MUTE_MEMBERS']) > 0;
    this.deafenMembers =
        (this.raw & _Constants.permissions['DEAFEN_MEMBERS']) > 0;
    this.moveMembers = (this.raw & _Constants.permissions['MOVE_MEMBERS']) > 0;
    this.useVad = (this.raw & _Constants.permissions['USE_VAD']) > 0;
    this.changeNickname =
        (this.raw & _Constants.permissions['CHANGE_NICKNAME']) > 0;
    this.manageNicknames =
        (this.raw & _Constants.permissions['MANAGE_NICKNAMES']) > 0;
    this.manageRoles =
        (this.raw & _Constants.permissions['MANAGE_ROLES_OR_PERMISSIONS']) > 0;
    this.manageWebhooks =
        (this.raw & _Constants.permissions['MANAGE_WEBHOOKS']) > 0;
  }
}
