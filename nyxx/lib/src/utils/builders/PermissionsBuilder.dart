part of nyxx;

/// Set of permissions ints
class _PermissionsSet {
  int allow = 0;
  int deny = 0;

  Map<String, dynamic> _build() => {"allow": allow, "deny": deny};
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

  _PermissionsSet _build() {
    final tmp = _PermissionsSet();

    _apply(tmp, this.createInstantInvite, PermissionsConstants.createInstantInvite);
    _apply(tmp, this.kickMembers, PermissionsConstants.kickMembers);
    _apply(tmp, this.banMembers, PermissionsConstants.banMembers);
    _apply(tmp, this.administrator, PermissionsConstants.administrator);
    _apply(tmp, this.manageChannels, PermissionsConstants.manageChannels);
    _apply(tmp, this.addReactions, PermissionsConstants.addReactions);
    _apply(tmp, this.viewAuditLog, PermissionsConstants.viewAuditLog);
    _apply(tmp, this.viewChannel, PermissionsConstants.viewChannel);
    _apply(tmp, this.manageGuild, PermissionsConstants.manageGuild);
    _apply(tmp, this.sendMessages, PermissionsConstants.sendMessages);
    _apply(tmp, this.sendTtsMessages, PermissionsConstants.sendTtsMessages);
    _apply(tmp, this.manageMessages, PermissionsConstants.manageMessages);
    _apply(tmp, this.embedLinks, PermissionsConstants.embedLinks);
    _apply(tmp, this.attachFiles, PermissionsConstants.attachFiles);
    _apply(tmp, this.readMessageHistory, PermissionsConstants.readMessageHistory);
    _apply(tmp, this.mentionEveryone, PermissionsConstants.mentionEveryone);
    _apply(tmp, this.useExternalEmojis, PermissionsConstants.externalEmojis);
    _apply(tmp, this.connect, PermissionsConstants.connect);
    _apply(tmp, this.speak, PermissionsConstants.speak);
    _apply(tmp, this.muteMembers, PermissionsConstants.muteMembers);
    _apply(tmp, this.deafenMembers, PermissionsConstants.deafenMembers);
    _apply(tmp, this.moveMembers, PermissionsConstants.moveMembers);
    _apply(tmp, this.useVad, PermissionsConstants.useVad);
    _apply(tmp, this.changeNickname, PermissionsConstants.changeNickname);
    _apply(tmp, this.manageNicknames, PermissionsConstants.manageNicknames);
    _apply(tmp, this.manageRoles, PermissionsConstants.manageRolesOrPermissions);
    _apply(tmp, this.manageWebhooks, PermissionsConstants.manageWebhooks);

    return tmp;
  }

  // TODO: NNBD - To consider
  void _apply(_PermissionsSet perm, bool? applies, int constant) {
    if(applies == null) {
      return;
    }

    if (applies) {
      perm.allow |= constant;
    } else {
      perm.deny |= constant;
    }
  }
}
