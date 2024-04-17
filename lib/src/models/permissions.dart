import 'package:nyxx/src/utils/flags.dart';

/// A set of permissions.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/permissions
class Permissions extends Flags<Permissions> {
  /// Allows creation of instant invites.
  static const createInstantInvite = Flag<Permissions>.fromOffset(0);

  /// Allows kicking members.
  static const kickMembers = Flag<Permissions>.fromOffset(1);

  /// Allows banning members.
  static const banMembers = Flag<Permissions>.fromOffset(2);

  /// Allows all permissions and bypasses channel permission overwrites.
  static const administrator = Flag<Permissions>.fromOffset(3);

  /// Allows management and editing of channels.
  static const manageChannels = Flag<Permissions>.fromOffset(4);

  /// Allows management and editing of the guild.
  static const manageGuild = Flag<Permissions>.fromOffset(5);

  /// Allows for the addition of reactions to messages.
  static const addReactions = Flag<Permissions>.fromOffset(6);

  /// Allows for viewing of audit logs.
  static const viewAuditLog = Flag<Permissions>.fromOffset(7);

  /// Allows for using priority speaker in a voice channel.
  static const prioritySpeaker = Flag<Permissions>.fromOffset(8);

  /// Allows the user to go live.
  static const stream = Flag<Permissions>.fromOffset(9);

  /// Allows guild members to view a channel, which includes reading messages in text channels and joining voice channels.
  static const viewChannel = Flag<Permissions>.fromOffset(10);

  /// Allows for sending messages in a channel and creating threads in a forum (does not allow sending messages in threads).
  static const sendMessages = Flag<Permissions>.fromOffset(11);

  /// Allows for sending of /tts messages.
  static const sendTtsMessages = Flag<Permissions>.fromOffset(12);

  /// Allows for deletion of other users messages.
  static const manageMessages = Flag<Permissions>.fromOffset(13);

  /// Links sent by users with this permission will be auto-embedded.
  static const embedLinks = Flag<Permissions>.fromOffset(14);

  /// Allows for uploading images and files.
  static const attachFiles = Flag<Permissions>.fromOffset(15);

  /// Allows for reading of message history.
  static const readMessageHistory = Flag<Permissions>.fromOffset(16);

  /// Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel.
  static const mentionEveryone = Flag<Permissions>.fromOffset(17);

  /// Allows the usage of custom emojis from other servers.
  static const useExternalEmojis = Flag<Permissions>.fromOffset(18);

  /// Allows for viewing guild insights.
  static const viewGuildInsights = Flag<Permissions>.fromOffset(19);

  /// Allows for joining of a voice channel.
  static const connect = Flag<Permissions>.fromOffset(20);

  /// Allows for speaking in a voice channel.
  static const speak = Flag<Permissions>.fromOffset(21);

  /// Allows for muting members in a voice channel.
  static const muteMembers = Flag<Permissions>.fromOffset(22);

  /// Allows for deafening of members in a voice channel.
  static const deafenMembers = Flag<Permissions>.fromOffset(23);

  /// Allows for moving of members between voice channels.
  static const moveMembers = Flag<Permissions>.fromOffset(24);

  /// Allows for using voice-activity-detection in a voice channel.
  static const useVad = Flag<Permissions>.fromOffset(25);

  /// Allows for modification of own nickname.
  static const changeNickname = Flag<Permissions>.fromOffset(26);

  /// Allows for modification of other users nicknames.
  static const manageNicknames = Flag<Permissions>.fromOffset(27);

  /// Allows management and editing of roles.
  static const manageRoles = Flag<Permissions>.fromOffset(28);

  /// Allows management and editing of webhooks.
  static const manageWebhooks = Flag<Permissions>.fromOffset(29);

  /// Allows for editing and deleting emojis, stickers, and soundboard sounds created by all users.
  static const manageEmojisAndStickers = Flag<Permissions>.fromOffset(30);

  /// Allows members to use application commands, including slash commands and context menu commands..
  static const useApplicationCommands = Flag<Permissions>.fromOffset(31);

  /// Allows for requesting to speak in stage channels. (This permission is under active development and may be changed or removed.).
  static const requestToSpeak = Flag<Permissions>.fromOffset(32);

  /// Allows for editing and deleting scheduled events created by all users.
  static const manageEvents = Flag<Permissions>.fromOffset(33);

  /// Allows for deleting and archiving threads, and viewing all private threads.
  static const manageThreads = Flag<Permissions>.fromOffset(34);

  /// Allows for creating public and announcement threads.
  static const createPublicThreads = Flag<Permissions>.fromOffset(35);

  /// Allows for creating private threads.
  static const createPrivateThreads = Flag<Permissions>.fromOffset(36);

  /// Allows the usage of custom stickers from other servers.
  static const useExternalStickers = Flag<Permissions>.fromOffset(37);

  /// Allows for sending messages in threads.
  static const sendMessagesInThreads = Flag<Permissions>.fromOffset(38);

  /// Allows for using Activities (applications with the EMBEDDED flag) in a voice channel.
  static const useEmbeddedActivities = Flag<Permissions>.fromOffset(39);

  /// Allows for timing out users to prevent them from sending or reacting to messages in chat and threads, and from speaking in voice and stage channels.
  static const moderateMembers = Flag<Permissions>.fromOffset(40);

  /// Allows for viewing role subscription insights.
  static const viewCreatorMonetizationAnalytics = Flag<Permissions>.fromOffset(41);

  /// Allows for using soundboard in a voice channel.
  static const useSoundboard = Flag<Permissions>.fromOffset(42);

  /// Allows for creating emojis, stickers, and soundboard sounds, and editing and deleting those created by the current user.
  static const createEmojiAndStickers = Flag<Permissions>.fromOffset(43);

  /// Allows for creating scheduled events, and editing and deleting those created by the current user.
  static const createEvents = Flag<Permissions>.fromOffset(44);

  /// Allows the usage of custom soundboard sounds from other servers.
  static const useExternalSounds = Flag<Permissions>.fromOffset(45);

  /// Allows sending voice messages.
  static const sendVoiceMessages = Flag<Permissions>.fromOffset(46);

  /// Allows sending polls.
  static const sendPolls = Flag<Permissions>.fromOffset(49);

  /// A [Permissions] with all permissions enabled.
  static const allPermissions = Permissions(140737488355327);

  /// Whether this set of permissions has the [createInstantInvite] permission.
  bool get canCreateInstantInvite => has(createInstantInvite);

  /// Whether this set of permissions has the [kickMembers] permission.
  bool get canKickMembers => has(kickMembers);

  /// Whether this set of permissions has the [banMembers] permission.
  bool get canBanMembers => has(banMembers);

  /// Whether this set of permissions has the [administrator] permission.
  bool get isAdministrator => has(administrator);

  /// Whether this set of permissions has the [manageChannels] permission.
  bool get canManageChannels => has(manageChannels);

  /// Whether this set of permissions has the [manageGuild] permission.
  bool get canManageGuild => has(manageGuild);

  /// Whether this set of permissions has the [addReactions] permission.
  bool get canAddReactions => has(addReactions);

  /// Whether this set of permissions has the [viewAuditLog] permission.
  bool get canViewAuditLog => has(viewAuditLog);

  /// Whether this set of permissions has the [prioritySpeaker] permission.
  bool get isPrioritySpeaker => has(prioritySpeaker);

  /// Whether this set of permissions has the [stream] permission.
  bool get canStream => has(stream);

  /// Whether this set of permissions has the [viewChannel] permission.
  bool get canViewChannel => has(viewChannel);

  /// Whether this set of permissions has the [sendMessages] permission.
  bool get canSendMessages => has(sendMessages);

  /// Whether this set of permissions has the [sendTtsMessages] permission.
  bool get canSendTtsMessages => has(sendTtsMessages);

  /// Whether this set of permissions has the [manageMessages] permission.
  bool get canManageMessages => has(manageMessages);

  /// Whether this set of permissions has the [embedLinks] permission.
  bool get canEmbedLinks => has(embedLinks);

  /// Whether this set of permissions has the [attachFiles] permission.
  bool get canAttachFiles => has(attachFiles);

  /// Whether this set of permissions has the [readMessageHistory] permission.
  bool get canReadMessageHistory => has(readMessageHistory);

  /// Whether this set of permissions has the [mentionEveryone] permission.
  bool get canMentionEveryone => has(mentionEveryone);

  /// Whether this set of permissions has the [useExternalEmojis] permission.
  bool get canUseExternalEmojis => has(useExternalEmojis);

  /// Whether this set of permissions has the [viewGuildInsights] permission.
  bool get canViewGuildInsights => has(viewGuildInsights);

  /// Whether this set of permissions has the [connect] permission.
  bool get canConnect => has(connect);

  /// Whether this set of permissions has the [speak] permission.
  bool get canSpeak => has(speak);

  /// Whether this set of permissions has the [muteMembers] permission.
  bool get canMuteMembers => has(muteMembers);

  /// Whether this set of permissions has the [deafenMembers] permission.
  bool get canDeafenMembers => has(deafenMembers);

  /// Whether this set of permissions has the [moveMembers] permission.
  bool get canMoveMembers => has(moveMembers);

  /// Whether this set of permissions has the [useVad] permission.
  bool get canUseVad => has(useVad);

  /// Whether this set of permissions has the [changeNickname] permission.
  bool get canChangeNickname => has(changeNickname);

  /// Whether this set of permissions has the [manageNicknames] permission.
  bool get canManageNicknames => has(manageNicknames);

  /// Whether this set of permissions has the [manageRoles] permission.
  bool get canManageRoles => has(manageRoles);

  /// Whether this set of permissions has the [manageWebhooks] permission.
  bool get canManageWebhooks => has(manageWebhooks);

  /// Whether this set of permissions has the [manageEmojisAndStickers] permission.
  bool get canManageEmojisAndStickers => has(manageEmojisAndStickers);

  /// Whether this set of permissions has the [useApplicationCommands] permission.
  bool get canUseApplicationCommands => has(useApplicationCommands);

  /// Whether this set of permissions has the [requestToSpeak] permission.
  bool get canRequestToSpeak => has(requestToSpeak);

  /// Whether this set of permissions has the [manageEvents] permission.
  bool get canManageEvents => has(manageEvents);

  /// Whether this set of permissions has the [manageThreads] permission.
  bool get canManageThreads => has(manageThreads);

  /// Whether this set of permissions has the [createPublicThreads] permission.
  bool get canCreatePublicThreads => has(createPublicThreads);

  /// Whether this set of permissions has the [createPrivateThreads] permission.
  bool get canCreatePrivateThreads => has(createPrivateThreads);

  /// Whether this set of permissions has the [useExternalStickers] permission.
  bool get canUseExternalStickers => has(useExternalStickers);

  /// Whether this set of permissions has the [sendMessagesInThreads] permission.
  bool get canSendMessagesInThreads => has(sendMessagesInThreads);

  /// Whether this set of permissions has the [useEmbeddedActivities] permission.
  bool get canUseEmbeddedActivities => has(useEmbeddedActivities);

  /// Whether this set of permissions has the [moderateMembers] permission.
  bool get canModerateMembers => has(moderateMembers);

  /// Whether this set of permissions has the [viewCreatorMonetizationAnalytics] permission.
  bool get canViewCreatorMonetizationAnalytics => has(viewCreatorMonetizationAnalytics);

  /// Whether this set of permissions has the [useSoundboard] permission.
  bool get canUseSoundboard => has(useSoundboard);

  /// Whether this set of permissions has the [createEmojiAndStickers] permission.
  bool get canCreateEmojiAndStickers => has(createEmojiAndStickers);

  /// Whether this set of permissions has the [createEvents] permission.
  bool get canCreateEvents => has(createEvents);

  /// Whether this set of permissions has the [useExternalSounds] permission.
  bool get canUseExternalSounds => has(useExternalSounds);

  /// Whether this set of permissions has the [sendVoiceMessages] permission.
  bool get canSendVoiceMessages => has(sendVoiceMessages);

  /// Whether this set of permissions has the [sendPolls] permission.
  bool get canSendPolls => has(sendPolls);

  /// Create a new [Permissions] from a permissions value.
  const Permissions(super.value);
}
