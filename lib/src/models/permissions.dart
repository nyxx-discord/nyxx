import 'package:nyxx/src/utils/flags.dart';

class Permissions extends Flags<Permissions> {
  static const createInstantInvite = Flag<Permissions>.fromOffset(0);
  static const kickMembers = Flag<Permissions>.fromOffset(1);
  static const banMembers = Flag<Permissions>.fromOffset(2);
  static const administrator = Flag<Permissions>.fromOffset(3);
  static const manageChannels = Flag<Permissions>.fromOffset(4);
  static const manageGuild = Flag<Permissions>.fromOffset(5);
  static const addReactions = Flag<Permissions>.fromOffset(6);
  static const viewAuditLog = Flag<Permissions>.fromOffset(7);
  static const prioritySpeaker = Flag<Permissions>.fromOffset(8);
  static const stream = Flag<Permissions>.fromOffset(9);
  static const viewChannel = Flag<Permissions>.fromOffset(10);
  static const sendMessages = Flag<Permissions>.fromOffset(11);
  static const sendTtsMessages = Flag<Permissions>.fromOffset(12);
  static const manageMessages = Flag<Permissions>.fromOffset(13);
  static const embedLinks = Flag<Permissions>.fromOffset(14);
  static const attachFiles = Flag<Permissions>.fromOffset(15);
  static const readMessageHistory = Flag<Permissions>.fromOffset(16);
  static const mentionEveryone = Flag<Permissions>.fromOffset(17);
  static const useExternalEmojis = Flag<Permissions>.fromOffset(18);
  static const viewGuildInsights = Flag<Permissions>.fromOffset(19);
  static const connect = Flag<Permissions>.fromOffset(20);
  static const speak = Flag<Permissions>.fromOffset(21);
  static const muteMembers = Flag<Permissions>.fromOffset(22);
  static const deafenMembers = Flag<Permissions>.fromOffset(23);
  static const moveMembers = Flag<Permissions>.fromOffset(24);
  static const useVad = Flag<Permissions>.fromOffset(25);
  static const changeNickname = Flag<Permissions>.fromOffset(26);
  static const manageNicknames = Flag<Permissions>.fromOffset(27);
  static const manageRoles = Flag<Permissions>.fromOffset(28);
  static const manageWebhooks = Flag<Permissions>.fromOffset(29);
  static const manageEmojisAndStickers = Flag<Permissions>.fromOffset(30);
  static const useApplicationCommands = Flag<Permissions>.fromOffset(31);
  static const requestToSpeak = Flag<Permissions>.fromOffset(32);
  static const manageEvents = Flag<Permissions>.fromOffset(33);
  static const manageThreads = Flag<Permissions>.fromOffset(34);
  static const createPublicThreads = Flag<Permissions>.fromOffset(35);
  static const createPrivateThreads = Flag<Permissions>.fromOffset(36);
  static const useExternalStickers = Flag<Permissions>.fromOffset(37);
  static const sendMessagesInThreads = Flag<Permissions>.fromOffset(38);
  static const useEmbeddedActivities = Flag<Permissions>.fromOffset(39);
  static const moderateMembers = Flag<Permissions>.fromOffset(40);

  bool get canCreateInstantInvite => has(createInstantInvite);
  bool get canKickMembers => has(kickMembers);
  bool get canBanMembers => has(banMembers);
  bool get isAdministrator => has(administrator);
  bool get canManageChannels => has(manageChannels);
  bool get canManageGuild => has(manageGuild);
  bool get canAddReactions => has(addReactions);
  bool get canViewAuditLog => has(viewAuditLog);
  bool get isPrioritySpeaker => has(prioritySpeaker);
  bool get canStream => has(stream);
  bool get canViewChannel => has(viewChannel);
  bool get canSendMessages => has(sendMessages);
  bool get canSendTtsMessages => has(sendTtsMessages);
  bool get canManageMessages => has(manageMessages);
  bool get canEmbedLinks => has(embedLinks);
  bool get canAttachFiles => has(attachFiles);
  bool get canReadMessageHistory => has(readMessageHistory);
  bool get canMentionEveryone => has(mentionEveryone);
  bool get canUseExternalEmojis => has(useExternalEmojis);
  bool get canViewGuildInsights => has(viewGuildInsights);
  bool get canConnect => has(connect);
  bool get canSpeak => has(speak);
  bool get canMuteMembers => has(muteMembers);
  bool get canDeafenMembers => has(deafenMembers);
  bool get canMoveMembers => has(moveMembers);
  bool get canUseVad => has(useVad);
  bool get canChangeNickname => has(changeNickname);
  bool get canManageNicknames => has(manageNicknames);
  bool get canManageRoles => has(manageRoles);
  bool get canManageWebhooks => has(manageWebhooks);
  bool get canManageEmojisAndStickers => has(manageEmojisAndStickers);
  bool get canUseApplicationCommands => has(useApplicationCommands);
  bool get canRequestToSpeak => has(requestToSpeak);
  bool get canManageEvents => has(manageEvents);
  bool get canManageThreads => has(manageThreads);
  bool get canCreatePublicThreads => has(createPublicThreads);
  bool get canCreatePrivateThreads => has(createPrivateThreads);
  bool get canUseExternalStickers => has(useExternalStickers);
  bool get canSendMessagesInThreads => has(sendMessagesInThreads);
  bool get canUseEmbeddedActivities => has(useEmbeddedActivities);
  bool get canModerateMembers => has(moderateMembers);

  const Permissions(super.value);
}
