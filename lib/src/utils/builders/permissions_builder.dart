import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/permissions/permissions_constants.dart';
import 'package:nyxx/src/typedefs.dart';

/// Set of permissions ints
class _PermissionsSet {
  int allow = 0;
  int deny = 0;

  RawApiMap build() => {"allow": allow, "deny": deny};
}

/// Builder for manipulating [PermissionsOverrides]. Created from existing override or manually by passing [type] and [id] of enttiy.
class PermissionOverrideBuilder extends PermissionsBuilder {
  /// Type of permission override either `role` or `member`
  final int type;

  /// Id of entity of permission override
  final Snowflake id;

  /// Create builder manually from known data. Id is id of entity. [type] can be either 0 for `role` or 1 for `member`.
  PermissionOverrideBuilder.from(this.type, this.id, Permissions permissions) : super.from(permissions);

  /// Create empty permission builder
  PermissionOverrideBuilder(this.type, this.id) : super();

  /// Create [PermissionsOverrides] for given [entity]. Entity have to be either [Role] or [Member]
  PermissionOverrideBuilder.of(SnowflakeEntity entity)
      : type = entity is IRole ? 0 : 1,
        id = entity.id,
        super();
}

/// Builder for permissions.
class PermissionsBuilder {
  /// The raw permission code.
  int? raw;

  /// True if user can create InstantInvite
  bool? createInstantInvite;

  /// True if user can kick members
  bool? kickMembers;

  /// True if user can ban members
  bool? banMembers;

  /// True if user is administrator
  bool? administrator;

  /// True if user can manager channels
  bool? manageChannels;

  /// True if user can manager guilds
  bool? manageGuild;

  /// Allows to add reactions
  bool? addReactions;

  /// Allows for using priority speaker in a voice channel
  bool? prioritySpeaker;

  /// Allow to view audit logs
  bool? viewAuditLog;

  /// Allow viewing channels (OLD READ_MESSAGES)
  bool? viewChannel;

  /// True if user can send messages
  bool? sendMessages;

  /// True if user can send messages in threads
  bool? sendMessagesInThreads;

  /// True if user can send TTF messages
  bool? sendTtsMessages;

  /// True if user can manage messages
  bool? manageMessages;

  /// True if user can send links in messages
  bool? embedLinks;

  /// True if user can attach files in messages
  bool? attachFiles;

  /// True if user can read messages history
  bool? readMessageHistory;

  /// True if user can mention everyone
  bool? mentionEveryone;

  /// True if user can use external emojis
  bool? useExternalEmojis;

  /// True if user can connect to voice channel
  bool? connect;

  /// True if user can speak
  bool? speak;

  /// True if user can mute members
  bool? muteMembers;

  /// True if user can deafen members
  bool? deafenMembers;

  /// True if user can move members
  bool? moveMembers;

  /// Allows for using voice-activity-detection in a voice channel
  bool? useVad;

  /// True if user can change nick
  bool? changeNickname;

  /// True if user can manager others nicknames
  bool? manageNicknames;

  /// True if user can manage server's roles
  bool? manageRoles;

  /// True if user can manage webhooks
  bool? manageWebhooks;

  /// Allows management and editing of emojis
  bool? manageEmojis;

  /// Allows the user to go live
  bool? stream;

  /// Allows for viewing guild insights
  bool? viewGuildInsights;

  /// Allows for deleting and archiving threads, and viewing all private threads
  bool? manageThreads;

  /// Allows for creating and participating in threads
  bool? createPublicThreads;

  /// Allows for creating and participating in private threads
  bool? createPrivateThreads;

  /// Empty permission builder
  PermissionsBuilder();

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
      ..manageEmojis = permissions.manageEmojis
      ..stream = permissions.stream
      ..viewGuildInsights = permissions.viewGuildInsights
      ..manageThreads = permissions.manageThreads
      ..createPublicThreads = permissions.createPublicThreads
      ..createPrivateThreads = permissions.createPrivateThreads;
  }

  /// Calculates permission int
  int calculatePermissionValue() {
    final set = this.build();

    return set.allow & ~set.deny;
  }

  _PermissionsSet build() {
    final permissionSet = _PermissionsSet();

    _apply(permissionSet, this.createInstantInvite, PermissionsConstants.createInstantInvite);
    _apply(permissionSet, this.kickMembers, PermissionsConstants.kickMembers);
    _apply(permissionSet, this.banMembers, PermissionsConstants.banMembers);
    _apply(permissionSet, this.administrator, PermissionsConstants.administrator);
    _apply(permissionSet, this.manageChannels, PermissionsConstants.manageChannels);
    _apply(permissionSet, this.addReactions, PermissionsConstants.addReactions);
    _apply(permissionSet, this.viewAuditLog, PermissionsConstants.viewAuditLog);
    _apply(permissionSet, this.viewChannel, PermissionsConstants.viewChannel);
    _apply(permissionSet, this.manageGuild, PermissionsConstants.manageGuild);
    _apply(permissionSet, this.sendMessages, PermissionsConstants.sendMessages);
    _apply(permissionSet, this.sendTtsMessages, PermissionsConstants.sendTtsMessages);
    _apply(permissionSet, this.manageMessages, PermissionsConstants.manageMessages);
    _apply(permissionSet, this.embedLinks, PermissionsConstants.embedLinks);
    _apply(permissionSet, this.attachFiles, PermissionsConstants.attachFiles);
    _apply(permissionSet, this.readMessageHistory, PermissionsConstants.readMessageHistory);
    _apply(permissionSet, this.mentionEveryone, PermissionsConstants.mentionEveryone);
    _apply(permissionSet, this.useExternalEmojis, PermissionsConstants.externalEmojis);
    _apply(permissionSet, this.connect, PermissionsConstants.connect);
    _apply(permissionSet, this.speak, PermissionsConstants.speak);
    _apply(permissionSet, this.muteMembers, PermissionsConstants.muteMembers);
    _apply(permissionSet, this.deafenMembers, PermissionsConstants.deafenMembers);
    _apply(permissionSet, this.moveMembers, PermissionsConstants.moveMembers);
    _apply(permissionSet, this.useVad, PermissionsConstants.useVad);
    _apply(permissionSet, this.changeNickname, PermissionsConstants.changeNickname);
    _apply(permissionSet, this.manageNicknames, PermissionsConstants.manageNicknames);
    _apply(permissionSet, this.manageRoles, PermissionsConstants.manageRolesOrPermissions);
    _apply(permissionSet, this.manageWebhooks, PermissionsConstants.manageWebhooks);
    _apply(permissionSet, this.viewGuildInsights, PermissionsConstants.viewGuildInsights);
    _apply(permissionSet, this.stream, PermissionsConstants.stream);
    _apply(permissionSet, this.manageEmojis, PermissionsConstants.manageEmojis);
    _apply(permissionSet, this.manageThreads, PermissionsConstants.manageThreads);
    _apply(permissionSet, this.createPublicThreads, PermissionsConstants.createPublicThreads);
    _apply(permissionSet, this.createPrivateThreads, PermissionsConstants.createPrivateThreads);

    return permissionSet;
  }

  // TODO: NNBD - To consider
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
