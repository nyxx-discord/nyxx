part of nyxx;

/// Contains constants for permissions
class PermissionsConstants {
  /// Allows to create instnt invite
  static const int createInstantInvite = 1 << 0;

  /// Allows to kick members
  static const int kickMembers = 1 << 1;

  /// Allows to ban members
  static const int banMembers = 1 << 2;

  /// Given to administrator
  static const int administrator = 1 << 3;

  /// Allows to manage channels(renaming, changing permissions)
  static const int manageChannels = 1 << 4;

  /// Allows to manager guild
  static const int manageGuild = 1 << 5;

  /// Allows for the addition of reactions to messages
  static const int addReactions = 1 << 6;

  /// Allows for viewing of audit logs
  static const int viewAuditLog = 1 << 7;

  /// Allows for using priority speaker in a voice channel
  static const int prioritySpeaker = 1 << 8;

  /// Allows guild members to view a channel, which includes reading messages in text channels
  static const int viewChannel = 1 << 10;

  /// Allows to send messages
  static const int sendMessages = 1 << 11;

  /// Allows to send TTS messages
  static const int sendTtsMessages = 1 << 12;

  /// Allows to deletes, edit messages
  static const int manageMessages = 1 << 13;

  /// Links sent by users with this permission will be auto-embedded
  static const int embedLinks = 1 << 14;

  /// Allows for uploading images and files
  static const int attachFiles = 1 << 15;

  /// Allows for reading of message history
  static const int readMessageHistory = 1 << 16;

  /// Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel
  static const int mentionEveryone = 1 << 17;

  /// Allows the usage of custom emojis from other servers
  static const int externalEmojis = 1 << 18;

  /// Allows for joining of a voice channel
  static const int connect = 1 << 20;

  /// Allows for speaking in a voice channel
  static const int speak = 1 << 21;

  /// Allows for muting members in a voice channel
  static const int muteMembers = 1 << 22;

  /// Allows for deafening of members in a voice channel
  static const int deafenMembers = 1 << 23;

  /// Allows for moving of members between voice channels
  static const int moveMembers = 1 << 24;

  /// Allows for using voice-activity-detection in a voice channel
  static const int useVad = 1 << 25;

  /// Allows for modification of own nickname
  static const int changeNickname = 1 << 26;

  /// Allows for modification of other users nicknames
  static const int manageNicknames = 1 << 27;

  /// Allows management and editing of roles
  static const int manageRolesOrPermissions = 1 << 28;

  /// Allows management and editing of webhooks
  static const int manageWebhooks = 1 << 29;

  /// Allows management and editing of emojis
  static const int manageEmojis = 1 << 30;
}
