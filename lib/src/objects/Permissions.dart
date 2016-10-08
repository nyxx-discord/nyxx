import '../internal/constants.dart';

/// Permissions for a role or channel override.
class Permissions {
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
    this.createInstantInvite = (permissions & Constants.permissions['CREATE_INSTANT_INVITE']) > 0;
  }
}