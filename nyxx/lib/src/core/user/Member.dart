part of nyxx;

/// A user with [Guild] context.
class Member extends User implements GuildEntity {
  /// The members nickname, null if not set.
  String? nickname;

  /// When the member joined the guild.
  late final DateTime joinedAt;

  /// Weather or not the member is deafened.
  late final bool deaf;

  /// Weather or not the member is muted.
  late final bool mute;

  /// A list of [Role]s the member has.
  late List<Role> roles;

  /// The highest displayed role that a member has, null if they dont have any
  Role? hoistedRole;

  @override

  /// The guild that the member is a part of.
  Guild guild;

  /// Returns highest role for member
  Role get highestRole => roles.isEmpty ? guild.everyoneRole : roles.reduce((f, s) => f.position > s.position ? f : s);

  /// Color of highest role of user
  DiscordColor get color => highestRole.color;

  /// Voice state of member
  VoiceState? get voiceState => guild.voiceStates[this.id];

  /// Returns total permissions of user.
  Permissions get effectivePermissions {
    if (this == guild.owner) {
      return Permissions.all();
    }

    var total = guild.everyoneRole.permissions.raw;
    for (final role in roles) {
      total |= role.permissions.raw;

      if (PermissionsUtils.isApplied(total, PermissionsConstants.administrator)) {
        return Permissions.fromInt(PermissionsConstants.allPermissions);
      }
    }

    return Permissions.fromInt(total);
  }

  factory Member._standard(Map<String, dynamic> data, Guild guild, Nyxx client) =>
    Member._new(data, data["user"] as Map<String, dynamic>, guild, client);

  factory Member._fromUser(Map<String, dynamic> dataUser, Map<String, dynamic> dataMember, Guild guild, Nyxx client) =>
    Member._new(dataMember, dataUser, guild, client);

  Member._new(Map<String, dynamic> raw, Map<String, dynamic> user, this.guild, Nyxx client) : super._new(user, client) {
    this.nickname = raw["nick"] as String?;
    this.deaf = raw["deaf"] as bool;
    this.mute = raw["mute"] as bool;

    this.roles = [for (var id in raw["roles"]) guild.roles[Snowflake(id)] as Role];

    if (raw["hoisted_role"] != null && roles.isNotEmpty) {
      // TODO: NNBD: try-catch in where
      try {
        this.hoistedRole = this.roles.firstWhere((element) => element.id == Snowflake(raw["hoisted_role"]));
      } on Exception {
        this.hoistedRole = null;
      }
    }

    if (raw["joined_at"] != null) {
      this.joinedAt = DateTime.parse(raw["joined_at"] as String).toUtc();
    }

    if (raw["game"] != null) {
      this.presence = Activity._new(raw["game"] as Map<String, dynamic>);
    }
  }

  bool _updateMember(String? nickname, List<Role> roles) {
    var changed = false;

    if (this.nickname != nickname) {
      this.nickname = nickname;
      changed = true;
    }

    if (this.roles != roles) {
      this.roles = roles;
      changed = true;
    }

    return changed;
  }

  /// Checks if member has specified role. Returns true if user is assigned to given role.
  bool hasRole(bool Function(Role role) func) => this.roles.any(func);

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason}) async {
    final body = <String, dynamic>{
      if (deleteMessageDays != null) "delete-message-days": deleteMessageDays,
      if (reason != null) "reason": reason
    };

    return client._http._execute(BasicRequest._new("/guilds/${this.guild.id}/bans/${this.id}",
        method: "PUT", auditLog: auditReason, body: body));
  }

  /// Adds role to user
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(Role role, {String? auditReason}) =>
    client._http._execute(BasicRequest._new("/guilds/${guild.id}/members/${this.id}/roles/${role.id}",
        method: "PUT", auditLog: auditReason));

  /// Removes [role] from user.
  Future<void> removeRole(Role role, {String? auditReason}) =>
    client._http._execute(BasicRequest._new(
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}/roles/${role.id.toString()}",
        method: "DELETE",
        auditLog: auditReason));

  /// Kicks the member from guild
  Future<void> kick({String? auditReason}) =>
    client._http._execute(
        BasicRequest._new("/guilds/${this.guild.id}/members/${this.id}", method: "DELETE", auditLog: auditReason));

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  Future<void> edit(
      {String? nick, List<Role>? roles, bool? mute, bool? deaf, CacheVoiceChannel? channel, String? auditReason}) {
    final body = <String, dynamic>{
      if (nick != null) "nick": nick,
      if (roles != null) "roles": roles.map((f) => f.id.toString()).toList(),
      if (mute != null) "mute": mute,
      if (deaf != null) "deaf": deaf,
      if (channel != null) "channel_id": channel.id.toString()
    };

    return client._http._execute(BasicRequest._new("/guilds/${this.guild.id.toString()}/members/${this.id.toString()}",
        method: "PATCH", auditLog: auditReason, body: body));
  }

  @override
  String toString() => super.toString();
}
