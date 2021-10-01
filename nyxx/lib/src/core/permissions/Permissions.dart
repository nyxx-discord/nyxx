part of nyxx;

/// Permissions for a role or channel override.
class Permissions implements Convertable<PermissionsBuilder> {
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

  /// True if user can send messages in threads
  late final bool sendMessagesInThreads;

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

  /// Allows management and editing of emojis
  late final bool manageEmojis;

  /// Allows the user to go live
  late final bool stream;

  /// Allows for viewing guild insights
  late final bool viewGuildInsights;

  /// Allows members to use slash commands in text channels
  late final bool useSlashCommands;

  /// Allows for requesting to speak in stage channels
  late final bool requestToSpeak;

  /// Allows for deleting and archiving threads, and viewing all private threads
  late final bool manageThreads;

  /// Allows for creating and participating in threads
  late final bool createPublicThreads;

  /// Allows for creating and participating in private threads
  late final bool createPrivateThreads;

  /// Allows the usage of custom stickers from other servers
  late final bool useExternalStickers;

  /// Allows for launching activities in a voice channel
  late final bool startEmbeddedActivities;
	
  /// Makes a [Permissions] object from a raw permission code.
  factory Permissions.fromInt(int permissions) =>
      Permissions._construct(permissions);

  /// Permissions with value of 0
  factory Permissions.empty() =>
      Permissions._construct(0);

  /// Permissions with max value
  factory Permissions.all() =>
      Permissions._construct(PermissionsConstants.allPermissions);

  /// Makes a [Permissions] object from overwrite object
  factory Permissions.fromOverwrite(int permissions, int allow, int deny) =>
      Permissions._construct(PermissionsUtils.apply(permissions, allow, deny));

  Permissions._construct(this.raw) {
    this.createInstantInvite = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.createInstantInvite);
    this.kickMembers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.kickMembers);
    this.banMembers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.banMembers);
    this.administrator = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.administrator);
    this.manageChannels = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageChannels);
    this.manageGuild = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageGuild);
    this.addReactions = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.addReactions);
    this.viewAuditLog = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.viewAuditLog);
    this.viewChannel = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.viewChannel);
    this.sendMessages = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.sendMessages);
     this.sendMessagesInThreads = PermissionsUtils.isApplied(
       this.raw, PermissionsConstants.sendMessagesInThread);
    this.prioritySpeaker = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.prioritySpeaker);
    this.sendTtsMessages = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.sendTtsMessages);
    this.manageMessages = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageMessages);
    this.embedLinks = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.embedLinks);
    this.attachFiles = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.attachFiles);
    this.readMessageHistory = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.readMessageHistory);
    this.mentionEveryone = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.mentionEveryone);
    this.useExternalEmojis = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.externalEmojis);
    this.connect =
        PermissionsUtils.isApplied(this.raw, PermissionsConstants.connect);
    this.speak =
        PermissionsUtils.isApplied(this.raw, PermissionsConstants.speak);
    this.muteMembers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.muteMembers);
    this.deafenMembers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.deafenMembers);
    this.moveMembers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.moveMembers);
    this.useVad =
        PermissionsUtils.isApplied(this.raw, PermissionsConstants.useVad);
    this.changeNickname = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.changeNickname);
    this.manageNicknames = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageNicknames);
    this.manageRoles = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageRolesOrPermissions);
    this.manageWebhooks = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageWebhooks);

    this.manageEmojis = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageEmojis);
    this.stream =
        PermissionsUtils.isApplied(this.raw, PermissionsConstants.stream);
    this.viewGuildInsights = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.viewGuildInsights);

    this.useSlashCommands = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.useSlashCommands);
    this.requestToSpeak = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.useSlashCommands);

    this.manageThreads = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.manageThreads);
    this.createPublicThreads = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.createPublicThreads);
    this.createPrivateThreads = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.createPrivateThreads);
		
		this.useExternalStickers = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.useExternalStickers);

		this.startEmbeddedActivities = PermissionsUtils.isApplied(
        this.raw, PermissionsConstants.startEmbeddedActivities);
  }

  /// Returns true if this permissions has [permission]
  bool hasPermission(int permission) =>
      PermissionsUtils.isApplied(this.raw, permission);

  @override
  int get hashCode => raw.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is Permissions) return other.raw == this.raw;
    if (other is int) return other == this.raw;

    return false;
  }

  @override
  PermissionsBuilder toBuilder() => PermissionsBuilder.from(this);
}
