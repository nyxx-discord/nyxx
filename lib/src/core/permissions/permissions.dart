import 'package:nyxx/src/core/permissions/permissions_constants.dart';
import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/permissions.dart';

abstract class IPermissions implements Convertable<PermissionsBuilder> {
  /// The raw permission code.
  late final int raw;

  /// True if user can create InstantInvite.
  bool get createInstantInvite;

  /// True if user can kick members.
  bool get kickMembers;

  /// True if user can ban members.
  bool get banMembers;

  /// True if user is administrator.
  bool get administrator;

  /// True if user can manager channels.
  bool get manageChannels;

  /// True if user can manager guilds.
  bool get manageGuild;

  /// Allows to add reactions.
  bool get addReactions;

  /// Allow to view audit logs.
  bool get viewAuditLog;

  /// Allows for using priority speaker in a voice channel.
  bool get prioritySpeaker;

  /// Allows the user to go live.
  bool get stream;

  /// Allow viewing channels (OLD READ_MESSAGES)
  bool get viewChannel;

  /// True if user can send messages.
  bool get sendMessages;

  /// True if user can send TTS messages.
  bool get sendTtsMessages;

  /// True if user can manage messages.
  bool get manageMessages;

  /// True if user can send links in messages.
  bool get embedLinks;

  /// True if user can attach files in messages.
  bool get attachFiles;

  /// True if user can read messages history.
  bool get readMessageHistory;

  /// True if user can mention everyone.
  bool get mentionEveryone;

  /// True if user can use external emojis.
  bool get useExternalEmojis;

  /// Allows for viewing guild insights.
  bool get viewGuildInsights;

  /// True if user can connect to voice channel.
  bool get connect;

  /// True if user can speak.
  bool get speak;

  /// True if user can mute members.
  bool get muteMembers;

  /// True if user can deafen members.
  bool get deafenMembers;

  /// True if user can move members.
  bool get moveMembers;

  /// Allows for using voice-activity-detection in a voice channel.
  bool get useVad;

  /// True if user can change nick.
  bool get changeNickname;

  /// True if user can manager others nicknames.
  bool get manageNicknames;

  /// True if user can manage server's roles.
  bool get manageRoles;

  /// True if user can manage webhooks.
  bool get manageWebhooks;

  /// Allows management and editing of emojis and stickers.
  bool get manageEmojisAndStickers;

  /// Allows for creating, editing, and deleting scheduled events.
  bool get manageEvents;

  /// Allows members to use slash commands in text channels.
  bool get useSlashCommands;

  /// Allows for requesting to speak in stage channels.
  bool get requestToSpeak;

  /// Allows for deleting and archiving threads, and viewing all private threads.
  bool get manageThreads;

  /// Allows for creating and participating in threads.
  bool get createPublicThreads;

  /// Allows for creating and participating in private threads.
  bool get createPrivateThreads;

  /// Allows the usage of custom stickers from other servers.
  bool get useExternalStickers;

  /// True if user can send messages in threads.
  bool get sendMessagesInThreads;

  /// Allows for launching activities in a voice channel.
  bool get startEmbeddedActivities;

  /// Allows for timing out users to prevent them from sending or reacting to messages in chat and threads, and from speaking in voice and stage channels.
  bool get moderateMembers;

  /// Returns true if this permissions has [permission]
  bool hasPermission(int permission);
}

/// Permissions for a role or channel override.
class Permissions implements IPermissions {
  /// The raw permission code.
  @override
  late final int raw;

  /// True if user can create InstantInvite.
  @override
  bool get createInstantInvite => PermissionsUtils.isApplied(raw, PermissionsConstants.createInstantInvite);

  /// True if user can kick members.
  @override
  bool get kickMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.kickMembers);

  /// True if user can ban members.
  @override
  bool get banMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.banMembers);

  /// True if user is administrator.
  @override
  bool get administrator => PermissionsUtils.isApplied(raw, PermissionsConstants.administrator);

  /// True if user can manager channels.
  @override
  bool get manageChannels => PermissionsUtils.isApplied(raw, PermissionsConstants.manageChannels);

  /// True if user can manager guilds.
  @override
  bool get manageGuild => PermissionsUtils.isApplied(raw, PermissionsConstants.manageGuild);

  /// Allows to add reactions.
  @override
  bool get addReactions => PermissionsUtils.isApplied(raw, PermissionsConstants.addReactions);

  /// Allows for using priority speaker in a voice channel.
  @override
  bool get prioritySpeaker => PermissionsUtils.isApplied(raw, PermissionsConstants.prioritySpeaker);

  /// Allow to view audit logs.
  @override
  bool get viewAuditLog => PermissionsUtils.isApplied(raw, PermissionsConstants.viewAuditLog);

  /// Allow viewing channels (OLD READ_MESSAGES)
  @override
  bool get viewChannel => PermissionsUtils.isApplied(raw, PermissionsConstants.viewChannel);

  /// True if user can send messages.
  @override
  bool get sendMessages => PermissionsUtils.isApplied(raw, PermissionsConstants.sendMessages);

  /// True if user can send messages in threads.
  @override
  bool get sendMessagesInThreads => PermissionsUtils.isApplied(raw, PermissionsConstants.sendMessagesInThreads);

  /// True if user can send TTF messages.
  @override
  bool get sendTtsMessages => PermissionsUtils.isApplied(raw, PermissionsConstants.sendTtsMessages);

  /// True if user can manage messages.
  @override
  bool get manageMessages => PermissionsUtils.isApplied(raw, PermissionsConstants.manageMessages);

  /// True if user can send links in messages.
  @override
  bool get embedLinks => PermissionsUtils.isApplied(raw, PermissionsConstants.embedLinks);

  /// True if user can attach files in messages.
  @override
  bool get attachFiles => PermissionsUtils.isApplied(raw, PermissionsConstants.attachFiles);

  /// True if user can read messages history.
  @override
  bool get readMessageHistory => PermissionsUtils.isApplied(raw, PermissionsConstants.readMessageHistory);

  /// True if user can mention everyone.
  @override
  bool get mentionEveryone => PermissionsUtils.isApplied(raw, PermissionsConstants.mentionEveryone);

  /// True if user can use external emojis.
  @override
  bool get useExternalEmojis => PermissionsUtils.isApplied(raw, PermissionsConstants.useExternalEmojis);

  /// True if user can connect to voice channel.
  @override
  bool get connect => PermissionsUtils.isApplied(raw, PermissionsConstants.connect);

  /// True if user can speak.
  @override
  bool get speak => PermissionsUtils.isApplied(raw, PermissionsConstants.speak);

  /// True if user can mute members.
  @override
  bool get muteMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.muteMembers);

  /// True if user can deafen members.
  @override
  bool get deafenMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.deafenMembers);

  /// True if user can move members.
  @override
  bool get moveMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.moveMembers);

  /// Allows for using voice-activity-detection in a voice channel.
  @override
  bool get useVad => PermissionsUtils.isApplied(raw, PermissionsConstants.useVad);

  /// True if user can change nick.
  @override
  bool get changeNickname => PermissionsUtils.isApplied(raw, PermissionsConstants.changeNickname);

  /// True if user can manager others nicknames.
  @override
  bool get manageNicknames => PermissionsUtils.isApplied(raw, PermissionsConstants.manageNicknames);

  /// True if user can manage server's roles.
  @override
  bool get manageRoles => PermissionsUtils.isApplied(raw, PermissionsConstants.manageRoles);

  /// True if user can manage webhooks.
  @override
  bool get manageWebhooks => PermissionsUtils.isApplied(raw, PermissionsConstants.manageWebhooks);

  @override
  bool get manageEmojisAndStickers => PermissionsUtils.isApplied(raw, PermissionsConstants.manageEmojisAndStickers);

  /// Allows the user to go live.
  @override
  bool get stream => PermissionsUtils.isApplied(raw, PermissionsConstants.stream);

  /// Allows for viewing guild insights.
  @override
  bool get viewGuildInsights => PermissionsUtils.isApplied(raw, PermissionsConstants.viewGuildInsights);

  /// Allows members to use slash commands in text channels.
  @override
  bool get useSlashCommands => PermissionsUtils.isApplied(raw, PermissionsConstants.useSlashCommands);

  /// Allows for requesting to speak in stage channels.
  @override
  bool get requestToSpeak => PermissionsUtils.isApplied(raw, PermissionsConstants.useSlashCommands);

  /// Allows for deleting and archiving threads, and viewing all private threads.
  @override
  bool get manageThreads => PermissionsUtils.isApplied(raw, PermissionsConstants.manageThreads);

  /// Allows for creating and participating in threads.
  @override
  bool get createPublicThreads => PermissionsUtils.isApplied(raw, PermissionsConstants.createPublicThreads);

  /// Allows for creating and participating in private threads.
  @override
  bool get createPrivateThreads => PermissionsUtils.isApplied(raw, PermissionsConstants.createPrivateThreads);

  /// Allows the usage of custom stickers from other servers.
  @override
  bool get useExternalStickers => PermissionsUtils.isApplied(raw, PermissionsConstants.useExternalStickers);

  /// Allows for launching activities in a voice channel.
  @override
  bool get startEmbeddedActivities => PermissionsUtils.isApplied(raw, PermissionsConstants.startEmbeddedActivities);

  @override
  bool get moderateMembers => PermissionsUtils.isApplied(raw, PermissionsConstants.moderateMembers);

  @override
  bool get manageEvents => PermissionsUtils.isApplied(raw, PermissionsConstants.manageEvents);

  /// Creates an instance of [Permissions]
  Permissions(this.raw);

  /// Permissions with value of 0.
  factory Permissions.empty() => Permissions(0);

  /// Permissions with max value.
  factory Permissions.all() => Permissions(PermissionsConstants.allPermissions);

  /// Makes a [Permissions] object from overwrite object.
  factory Permissions.fromOverwrite(int permissions, int allow, int deny) => Permissions(PermissionsUtils.apply(permissions, allow, deny));

  /// Returns true if this permissions has [permission]
  @override
  bool hasPermission(int permission) => PermissionsUtils.isApplied(raw, permission);

  @override
  int get hashCode => raw.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is Permissions) return other.raw == raw;
    if (other is int) return other == raw;

    return false;
  }

  @override
  PermissionsBuilder toBuilder() => PermissionsBuilder.from(this);
}
