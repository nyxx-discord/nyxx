import '../internal/constants.dart';

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

  /// Makes a [Permissions] object from a raw permission code.
  Permissions.fromInt(int permissions) {
    this.raw = permissions;
    this.createInstantInvite = (this.raw & Constants.permissions['CREATE_INSTANT_INVITE']) > 0;
    this.kickMembers = (this.raw & Constants.permissions['KICK_MEMBERS']) > 0;
    this.banMembers = (this.raw & Constants.permissions['BAN_MEMBERS']) > 0;
    this.administrator = (this.raw & Constants.permissions['ADMINISTRATOR']) > 0;
    this.manageChannels = (this.raw & Constants.permissions['MANAGE_CHANNELS']) > 0;
    this.manageGuild = (this.raw & Constants.permissions['MANAGE_GUILD']) > 0;
    this.readMessages = (this.raw & Constants.permissions['READ_MESSAGES']) > 0;
    this.sendMessages = (this.raw & Constants.permissions['SEND_MESSAGES']) > 0;
    this.sendTtsMessages = (this.raw & Constants.permissions['SEND_TTS_MESSAGES']) > 0;
    this.manageMessages = (this.raw & Constants.permissions['MANAGE_MESSAGES']) > 0;
    this.embedLinks = (this.raw & Constants.permissions['EMBED_LINKS']) > 0;
    this.attachFiles = (this.raw & Constants.permissions['ATTACH_FILES']) > 0;
    this.readMessageHistory = (this.raw & Constants.permissions['READ_MESSAGE_HISTORY']) > 0;
    this.mentionEveryone = (this.raw & Constants.permissions['MENTION_EVERYONE']) > 0;
    this.useExternalEmojis = (this.raw & Constants.permissions['USE_EXTERNAL_EMOJIS']) > 0;
    this.connect = (this.raw & Constants.permissions['CONNECT']) > 0;
    this.speak = (this.raw & Constants.permissions['SPEAK']) > 0;
    this.muteMembers = (this.raw & Constants.permissions['MUTE_MEMBERS']) > 0;    
    this.deafenMembers = (this.raw & Constants.permissions['DEAFEN_MEMBERS']) > 0;    
    this.moveMembers = (this.raw & Constants.permissions['MOVE_MEMBERS']) > 0;    
    this.useVad = (this.raw & Constants.permissions['USE_VAD']) > 0;    
    this.changeNickname = (this.raw & Constants.permissions['CHANGE_NICKNAME']) > 0;    
    this.manageNicknames = (this.raw & Constants.permissions['MANAGE_NICKNAMES']) > 0;    
    this.manageRoles = (this.raw & Constants.permissions['MANAGE_ROLES']) > 0;            
  }
}