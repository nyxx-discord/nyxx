part of nyxx;

class PermissionsConstants {
  /// Allows to create instnt invite
  static const int CREATE_INSTANT_INVITE = 1 << 0;

  /// Allows to kick members
  static const int KICK_MEMBERS = 1 << 1;

  /// Allows to ban members
  static const int BAN_MEMBERS = 1 << 2;

  /// Given to administrator
  static const int ADMINISTRATOR = 1 << 3;

  /// Allows to manage channels(renaming, changing permissions)
  static const int MANAGE_CHANNELS = 1 << 4;

  /// Allows to manager guild
  static const int MANAGE_GUILD = 1 << 5;

  /// Allows for the addition of reactions to messages
  static const int ADD_REACTIONS = 1 << 6;

  /// Allows for viewing of audit logs
  static const int VIEW_AUDIT_LOG = 1 << 7;

  /// Allows guild members to view a channel, which includes reading messages in text channels
  static const int VIEW_CHANNEL = 1 << 10;

  /// Allows to send messages
  static const int SEND_MESSAGES = 1 << 11;

  /// Allows to send TTS messages
  static const int SEND_TTS_MESSAGES = 1 << 12;

  /// Allows to deletes, edit messages
  static const int MANAGE_MESSAGES = 1 << 13;

  /// Links sent by users with this permission will be auto-embedded
  static const int EMBED_LINKS = 1 << 14;

  /// Allows for uploading images and files
  static const int ATTACH_FILES = 1 << 15;

  /// Allows for reading of message history
  static const int READ_MESSAGE_HISTORY = 1 << 16;

  /// Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel
  static const int MENTION_EVERYONE = 1 << 17;

  /// Allows the usage of custom emojis from other servers
  static const int EXTERNAL_EMOJIS = 1 << 18;

  /// Allows for joining of a voice channel
  static const int CONNECT = 1 << 20;

  /// Allows for speaking in a voice channel
  static const int SPEAK = 1 << 21;

  /// Allows for muting members in a voice channel
  static const int MUTE_MEMBERS = 1 << 22;

  /// Allows for deafening of members in a voice channel
  static const int DEAFEN_MEMBERS = 1 << 23;

  /// Allows for moving of members between voice channels
  static const int MOVE_MEMBERS = 1 << 24;

  /// Allows for using voice-activity-detection in a voice channel
  static const int USE_VAD = 1 << 25;

  /// Allows for modification of own nickname
  static const int CHANGE_NICKNAME = 1 << 26;

  /// Allows for modification of other users nicknames
  static const int MANAGE_NICKNAMES = 1 << 27;

  /// Allows management and editing of roles
  static const int MANAGE_ROLES_OR_PERMISSIONS = 1 << 28;

  /// Allows management and editing of webhooks
  static const int MANAGE_WEBHOOKS = 1 << 29;

  /// Allows management and editing of emojis
  static const int MANAGE_EMOJIS = 1 << 30;
}
