part of discord;

/// Permissions for a role or channel override.
class Permissions extends _BaseObj {
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
  Permissions.fromInt(Client client, int permissions) : super(client) {
    this.raw = this._map['raw'] = permissions;
    this.createInstantInvite = this._map['createInstantInvite'] =
        (this.raw & _Constants.permissions['CREATE_INSTANT_INVITE']) > 0;
    this.kickMembers = this._map['kickMembers'] =
        (this.raw & _Constants.permissions['KICK_MEMBERS']) > 0;
    this.banMembers = this._map['banMembers'] =
        (this.raw & _Constants.permissions['BAN_MEMBERS']) > 0;
    this.administrator = this._map['administrator'] =
        (this.raw & _Constants.permissions['ADMINISTRATOR']) > 0;
    this.manageChannels = this._map['manageChannels'] =
        (this.raw & _Constants.permissions['MANAGE_CHANNELS']) > 0;
    this.manageGuild = this._map['manageGuild'] =
        (this.raw & _Constants.permissions['MANAGE_GUILD']) > 0;
    this.readMessages = this._map['readMessages'] =
        (this.raw & _Constants.permissions['READ_MESSAGES']) > 0;
    this.sendMessages = this._map['sendMessages'] =
        (this.raw & _Constants.permissions['SEND_MESSAGES']) > 0;
    this.sendTtsMessages = this._map['sendTtsMessages'] =
        (this.raw & _Constants.permissions['SEND_TTS_MESSAGES']) > 0;
    this.manageMessages = this._map['manageMessages'] =
        (this.raw & _Constants.permissions['MANAGE_MESSAGES']) > 0;
    this.embedLinks = this._map['embedLinks'] =
        (this.raw & _Constants.permissions['EMBED_LINKS']) > 0;
    this.attachFiles = this._map['attachFiles'] =
        (this.raw & _Constants.permissions['ATTACH_FILES']) > 0;
    this.readMessageHistory = this._map['readMessageHistory'] =
        (this.raw & _Constants.permissions['READ_MESSAGE_HISTORY']) > 0;
    this.mentionEveryone = this._map['mentionEveryone'] =
        (this.raw & _Constants.permissions['MENTION_EVERYONE']) > 0;
    this.useExternalEmojis = this._map['useExternalEmojis'] =
        (this.raw & _Constants.permissions['EXTERNAL_EMOJIS']) > 0;
    this.connect = this._map['connect'] =
        (this.raw & _Constants.permissions['CONNECT']) > 0;
    this.speak =
        this._map['speak'] = (this.raw & _Constants.permissions['SPEAK']) > 0;
    this.muteMembers = this._map['muteMembers'] =
        (this.raw & _Constants.permissions['MUTE_MEMBERS']) > 0;
    this.deafenMembers = this._map['deafenMembers'] =
        (this.raw & _Constants.permissions['DEAFEN_MEMBERS']) > 0;
    this.moveMembers = this._map['moveMembers'] =
        (this.raw & _Constants.permissions['MOVE_MEMBERS']) > 0;
    this.useVad = this._map['useVad'] =
        (this.raw & _Constants.permissions['USE_VAD']) > 0;
    this.changeNickname = this._map['changeNickname'] =
        (this.raw & _Constants.permissions['CHANGE_NICKNAME']) > 0;
    this.manageNicknames = this._map['manageNicknames'] =
        (this.raw & _Constants.permissions['MANAGE_NICKNAMES']) > 0;
    this.manageRoles = this._map['manageRoles'] =
        (this.raw & _Constants.permissions['MANAGE_ROLES_OR_PERMISSIONS']) > 0;
    this.manageWebhooks = this._map['manageWebhooks'] =
        (this.raw & _Constants.permissions['MANAGE_WEBHOOKS']) > 0;

    this._map['key'] = this.raw;
  }
}
