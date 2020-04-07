part of nyxx;

/// Provides common properties for [Permissions] and [PermissionsBuilder]
abstract class AbstractPermissions {
  /// The raw permission code.
  late final int raw;

  /// True if user can create InstantInvite
  late final bool createInstantInvite;

  /// True if user can kick members
  late final bool kickMembers;

  /// True if user can ban members
  late final bool banMembers;

  /// True if user is administrator
  late final bool administrator;

  /// True if user can manager channels
  late final bool manageChannels;

  /// True if user can manager guilds
  late final bool manageGuild;

  /// Allows to add reactions
  late final bool addReactions;

  /// Allows for using priority speaker in a voice channel
  late final bool prioritySpeaker;

  /// Allow to view audit logs
  late final bool viewAuditLog;

  /// Allow viewing channels (OLD READ_MESSAGES)
  late final bool viewChannel;

  /// True if user can send messages
  late final bool sendMessages;

  /// True if user can send TTF messages
  late final bool sendTtsMessages;

  /// True if user can manage messages
  late final bool manageMessages;

  /// True if user can send links in messages
  late final bool embedLinks;

  /// True if user can attach files in messages
  late final bool attachFiles;

  /// True if user can read messages history
  late final bool readMessageHistory;

  /// True if user can mention everyone
  late final bool mentionEveryone;

  /// True if user can use external emojis
  late final bool useExternalEmojis;

  /// True if user can connect to voice channel
  late final bool connect;

  /// True if user can speak
  late final bool speak;

  /// True if user can mute members
  late final bool muteMembers;

  /// True if user can deafen members
  late final bool deafenMembers;

  /// True if user can move members
  late final bool moveMembers;

  /// Allows for using voice-activity-detection in a voice channel
  late final bool useVad;

  /// True if user can change nick
  late final bool changeNickname;

  /// True if user can manager others nicknames
  late final bool manageNicknames;

  /// True if user can manage server's roles
  late final bool manageRoles;

  /// True if user can manage webhooks
  late final bool manageWebhooks;
}
