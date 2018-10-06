part of nyxx;

/// Provides common properties for [Permissions] and [PermissionsBuilder]
abstract class AbstractPermissions {
  /// The raw permission code.
  int raw;

  /// True if user can create InstantInvite
  bool createInstantInvite;

  /// True if user can kick members
  bool kickMembers;

  /// True if user can ban members
  bool banMembers;

  /// True if user is administrator
  bool administrator;

  /// True if user can manager channels
  bool manageChannels;

  /// True if user can manager guilds
  bool manageGuild;

  /// Allows to add reactions
  bool addReactions;

  /// Allows for using priority speaker in a voice channel
  bool prioritySpeaker;

  /// Allow to view audit logs
  bool viewAuditLog;

  /// Allow viewing channels (OLD READ_MESSAGES)
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
}
