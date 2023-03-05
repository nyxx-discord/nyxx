import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';

/// Set of permissions ints
class _PermissionsSet extends Builder {
  int allow = 0;
  int deny = 0;

  @override
  RawApiMap build() => {"allow": allow, "deny": deny};
}

/// Builder for manipulating [PermissionsOverrides]. Created from existing override or manually by passing [type] and [id] of enttiy.
class PermissionOverrideBuilder extends PermissionsBuilder {
  /// Type of permission override either `role` or `member`
  final int type;

  /// Id of entity of permission override.
  final Snowflake id;

  /// Create builder manually from known data. Id is id of entity. [type] can be either 0 for `role` or 1 for `member`.
  PermissionOverrideBuilder.from(this.type, this.id, Permissions permissions) : super.from(permissions);

  /// Create empty permission builder.
  PermissionOverrideBuilder(this.type, this.id) : super();

  /// Create [PermissionsOverrides] for given [entity]. Entity have to be either [Role] or [Member]
  PermissionOverrideBuilder.of(SnowflakeEntity entity)
      : type = entity is IRole ? 0 : 1,
        id = entity.id,
        super();

  @override
  RawApiMap build() => {
        ...super.build(),
        "id": id.toString(),
        "type": type,
      };
}

/// Builder for permissions.
class PermissionsBuilder extends Builder {
  /// The raw permission code.
  int? raw;

  /// True if user can create InstantInvite.
  bool? createInstantInvite;

  /// True if user can kick members.
  bool? kickMembers;

  /// True if user can ban members.
  bool? banMembers;

  /// True if user is administrator.
  bool? administrator;

  /// True if user can manager channels.
  bool? manageChannels;

  /// True if user can manager guilds.
  bool? manageGuild;

  /// Allows to add reactions.
  bool? addReactions;

  /// Allows for using priority speaker in a voice channel.
  bool? prioritySpeaker;

  /// Allow to view audit logs.
  bool? viewAuditLog;

  /// Allow viewing channels (OLD READ_MESSAGES)
  bool? viewChannel;

  /// True if user can send messages.
  bool? sendMessages;

  /// True if user can send messages in threads.
  bool? sendMessagesInThreads;

  /// True if user can send TTF messages.
  bool? sendTtsMessages;

  /// True if user can manage messages.
  bool? manageMessages;

  /// True if user can send links in messages.
  bool? embedLinks;

  /// True if user can attach files in messages.
  bool? attachFiles;

  /// True if user can read messages history.
  bool? readMessageHistory;

  /// True if user can mention everyone.
  bool? mentionEveryone;

  /// True if user can use external emojis.
  bool? useExternalEmojis;

  /// Allows the usage of custom stickers from other servers.
  bool? useExternalStickers;

  /// Allows members to use application commands, including slash commands and context menu commands.
  bool? useSlashCommands;

  /// True if user can connect to voice channel.
  bool? connect;

  /// True if user can speak.
  bool? speak;

  /// True if user can mute members.
  bool? muteMembers;

  /// True if user can deafen members.
  bool? deafenMembers;

  /// True if user can move members.
  bool? moveMembers;

  /// Allows for using voice-activity-detection in a voice channel.
  bool? useVad;

  /// True if user can change nick.
  bool? changeNickname;

  /// True if user can manager others nicknames.
  bool? manageNicknames;

  /// True if user can manage server's roles.
  bool? manageRoles;

  /// True if user can manage webhooks.
  bool? manageWebhooks;

  /// Allows management and editing of emojis & stickers.
  bool? manageEmojisAndStickers;

  /// Allows for requesting to speak in stage channels. (This permission is under active development and may be changed or removed.).
  bool? requestToSpeak;

  /// Allows the user to go live.
  bool? stream;

  /// Allows for viewing guild insights.
  bool? viewGuildInsights;

  /// Allows for deleting and archiving threads, and viewing all private threads.
  bool? manageThreads;

  /// Allows for creating and participating in threads.
  bool? createPublicThreads;

  /// Allows for creating and participating in private threads.
  bool? createPrivateThreads;

  /// Allows for creating, editing, and deleting scheduled events.
  bool? manageEvents;

  /// Allows for timing out users to prevent them from sending or reacting to messages in chat and threads, and from speaking in voice and stage channels.
  bool? moderateMembers;

  PermissionsBuilder({
    this.addReactions,
    this.administrator,
    this.attachFiles,
    this.banMembers,
    this.changeNickname,
    this.connect,
    this.createInstantInvite,
    this.createPrivateThreads,
    this.createPublicThreads,
    this.deafenMembers,
    this.embedLinks,
    this.kickMembers,
    this.manageChannels,
    this.manageEmojisAndStickers,
    this.manageEvents,
    this.manageGuild,
    this.manageMessages,
    this.manageNicknames,
    this.manageRoles,
    this.manageThreads,
    this.manageWebhooks,
    this.mentionEveryone,
    this.moderateMembers,
    this.moveMembers,
    this.muteMembers,
    this.prioritySpeaker,
    this.readMessageHistory,
    this.sendMessages,
    this.requestToSpeak,
    this.sendMessagesInThreads,
    this.sendTtsMessages,
    this.speak,
    this.stream,
    this.useExternalEmojis,
    this.useExternalStickers,
    this.useSlashCommands,
    this.useVad,
    this.viewAuditLog,
    this.viewChannel,
    this.viewGuildInsights,
  });

  /// Permission builder from existing [Permissions] object.
  PermissionsBuilder.from(Permissions permissions) {
    this
      ..createInstantInvite = permissions.createInstantInvite
      ..kickMembers = permissions.kickMembers
      ..banMembers = permissions.banMembers
      ..administrator = permissions.administrator
      ..manageChannels = permissions.manageChannels
      ..manageGuild = permissions.manageGuild
      ..addReactions = permissions.addReactions
      ..viewAuditLog = permissions.viewAuditLog
      ..viewChannel = permissions.viewChannel
      ..sendMessages = permissions.sendMessages
      ..sendMessagesInThreads = permissions.sendMessagesInThreads
      ..prioritySpeaker = permissions.prioritySpeaker
      ..sendTtsMessages = permissions.sendTtsMessages
      ..manageMessages = permissions.manageMessages
      ..embedLinks = permissions.embedLinks
      ..attachFiles = permissions.attachFiles
      ..readMessageHistory = permissions.readMessageHistory
      ..mentionEveryone = permissions.mentionEveryone
      ..useExternalEmojis = permissions.useExternalEmojis
      ..connect = permissions.connect
      ..speak = permissions.speak
      ..muteMembers = permissions.muteMembers
      ..deafenMembers = permissions.deafenMembers
      ..moveMembers = permissions.moveMembers
      ..useVad = permissions.useVad
      ..changeNickname = permissions.changeNickname
      ..manageNicknames = permissions.manageNicknames
      ..manageRoles = permissions.manageRoles
      ..manageWebhooks = permissions.manageWebhooks
      ..manageEmojisAndStickers = permissions.manageEmojisAndStickers
      ..stream = permissions.stream
      ..viewGuildInsights = permissions.viewGuildInsights
      ..manageThreads = permissions.manageThreads
      ..createPublicThreads = permissions.createPublicThreads
      ..createPrivateThreads = permissions.createPrivateThreads
      ..moderateMembers = permissions.moderateMembers
      ..useSlashCommands = permissions.useSlashCommands
      ..requestToSpeak = permissions.requestToSpeak
      ..manageEvents = permissions.manageEvents
      ..useExternalStickers = permissions.useExternalStickers;
  }

  /// Calculates permission int.
  int calculatePermissionValue() {
    final set = _calculatePermissionSet();

    return set.allow & ~set.deny;
  }

  _PermissionsSet _calculatePermissionSet() {
    final permissionSet = _PermissionsSet();

    _apply(permissionSet, createInstantInvite, PermissionsConstants.createInstantInvite);
    _apply(permissionSet, kickMembers, PermissionsConstants.kickMembers);
    _apply(permissionSet, banMembers, PermissionsConstants.banMembers);
    _apply(permissionSet, administrator, PermissionsConstants.administrator);
    _apply(permissionSet, manageChannels, PermissionsConstants.manageChannels);
    _apply(permissionSet, addReactions, PermissionsConstants.addReactions);
    _apply(permissionSet, viewAuditLog, PermissionsConstants.viewAuditLog);
    _apply(permissionSet, viewChannel, PermissionsConstants.viewChannel);
    _apply(permissionSet, manageGuild, PermissionsConstants.manageGuild);
    _apply(permissionSet, sendMessages, PermissionsConstants.sendMessages);
    _apply(permissionSet, sendTtsMessages, PermissionsConstants.sendTtsMessages);
    _apply(permissionSet, manageMessages, PermissionsConstants.manageMessages);
    _apply(permissionSet, embedLinks, PermissionsConstants.embedLinks);
    _apply(permissionSet, attachFiles, PermissionsConstants.attachFiles);
    _apply(permissionSet, readMessageHistory, PermissionsConstants.readMessageHistory);
    _apply(permissionSet, mentionEveryone, PermissionsConstants.mentionEveryone);
    _apply(permissionSet, useExternalEmojis, PermissionsConstants.useExternalEmojis);
    _apply(permissionSet, connect, PermissionsConstants.connect);
    _apply(permissionSet, speak, PermissionsConstants.speak);
    _apply(permissionSet, muteMembers, PermissionsConstants.muteMembers);
    _apply(permissionSet, deafenMembers, PermissionsConstants.deafenMembers);
    _apply(permissionSet, moveMembers, PermissionsConstants.moveMembers);
    _apply(permissionSet, useVad, PermissionsConstants.useVad);
    _apply(permissionSet, changeNickname, PermissionsConstants.changeNickname);
    _apply(permissionSet, manageNicknames, PermissionsConstants.manageNicknames);
    _apply(permissionSet, manageRoles, PermissionsConstants.manageRoles);
    _apply(permissionSet, manageWebhooks, PermissionsConstants.manageWebhooks);
    _apply(permissionSet, viewGuildInsights, PermissionsConstants.viewGuildInsights);
    _apply(permissionSet, stream, PermissionsConstants.stream);
    _apply(permissionSet, manageEmojisAndStickers, PermissionsConstants.manageEmojisAndStickers);
    _apply(permissionSet, manageThreads, PermissionsConstants.manageThreads);
    _apply(permissionSet, createPublicThreads, PermissionsConstants.createPublicThreads);
    _apply(permissionSet, createPrivateThreads, PermissionsConstants.createPrivateThreads);
    _apply(permissionSet, moderateMembers, PermissionsConstants.moderateMembers);
    _apply(permissionSet, useExternalStickers, PermissionsConstants.useExternalStickers);
    _apply(permissionSet, useSlashCommands, PermissionsConstants.useSlashCommands);
    _apply(permissionSet, manageEvents, PermissionsConstants.manageEvents);
    _apply(permissionSet, requestToSpeak, PermissionsConstants.requestToSpeak);
    _apply(permissionSet, prioritySpeaker, PermissionsConstants.prioritySpeaker);
    _apply(permissionSet, sendMessagesInThreads, PermissionsConstants.sendMessagesInThreads);

    return permissionSet;
  }

  @override
  RawApiMap build() {
    _PermissionsSet permissionSet = _calculatePermissionSet();

    return {
      "allow": permissionSet.allow.toString(),
      "deny": permissionSet.deny.toString(),
    };
  }

  void _apply(_PermissionsSet perm, bool? applies, int constant) {
    if (applies == null) {
      return;
    }

    if (applies) {
      perm.allow |= constant;
    } else {
      perm.deny |= constant;
    }
  }
}
