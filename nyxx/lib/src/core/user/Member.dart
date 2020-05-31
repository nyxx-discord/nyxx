part of nyxx;

/// Represents [Guild] member. Can be either [CachelessMember] or [CacheMember] depending on client config and cache state.
/// Interface allows basic operations on member but does not guarantee data to be valid or available
abstract class IMember extends User {
 IMember._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, client);

 /// Checks if member has specified role. Returns true if user is assigned to given role.
 bool hasRole(bool Function(IRole role) func);

 /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
 Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason});

 /// Adds role to user
 ///
 /// ```
 /// var r = guild.roles.values.first;
 /// await member.addRole(r);
 /// ```
 Future<void> addRole(IRole role, {String? auditReason});

 /// Removes [role] from user.
 Future<void> removeRole(IRole role, {String? auditReason});
 /// Kicks the member from guild
 Future<void> kick({String? auditReason});

 /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
 Future<void> edit({String? nick, List<IRole>? roles, bool? mute, bool? deaf, VoiceChannel? channel, String? auditReason});
}

/// Stateless [IMember] instance. Does not have reference to guild.
class CachelessMember extends IMember {
  /// The members nickname, null if not set.
  String? nickname;

  /// When the member joined the guild.
  late final DateTime joinedAt;

  /// Weather or not the member is deafened.
  late final bool deaf;

  /// Weather or not the member is muted.
  late final bool mute;

  /// Id of guild
  final Snowflake guildId;

  /// Roles of member. It will contain instance of [IRole] if [CachelessMember] or instance of [Role] if instance of [CacheMember]
  late Iterable<IRole> roles;

  /// Highest role of member
  late IRole? hoistedRole;

  factory CachelessMember._standard(Map<String, dynamic> data, Snowflake guildId, Nyxx client) =>
      CachelessMember._new(data, data["user"] as Map<String, dynamic>, guildId, client);

  factory CachelessMember._fromUser(Map<String, dynamic> dataUser, Map<String, dynamic> dataMember, Snowflake guildId, Nyxx client) =>
      CachelessMember._new(dataMember, dataUser, guildId, client);

  CachelessMember._new(Map<String, dynamic> raw, Map<String, dynamic> userRaw, this.guildId, Nyxx client) : super._new(userRaw, client) {
    this.nickname = raw["nick"] as String?;
    this.deaf = raw["deaf"] as bool;
    this.mute = raw["mute"] as bool;

    this.roles = [for (var id in raw["roles"]) IRole._new(Snowflake(id), this.guildId, client)];

    if (raw["hoisted_role"] != null && roles.isNotEmpty) {
      // TODO: NNBD: try-catch in where
      try {
        this.hoistedRole = this.roles.firstWhere((element) => element.id == IRole._new(Snowflake(raw["hoisted_role"]), this.guildId, client));
      } on Error {
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

  bool _updateMember(String? nickname, List<IRole> roles) {
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
  @override
  bool hasRole(bool Function(IRole role) func) => this.roles.any(func);

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  @override
  Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason}) async {
    final body = <String, dynamic>{
      if (deleteMessageDays != null) "delete-message-days": deleteMessageDays,
      if (reason != null) "reason": reason
    };

    return client._http._execute(BasicRequest._new("/guilds/${this.guildId}/bans/${this.id}",
        method: "PUT", auditLog: auditReason, body: body));
  }

  /// Adds role to user
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  @override
  Future<void> addRole(IRole role, {String? auditReason}) =>
      client._http._execute(BasicRequest._new("/guilds/$guildId/members/${this.id}/roles/${role.id}",
          method: "PUT", auditLog: auditReason));

  /// Removes [role] from user.
  @override
  Future<void> removeRole(IRole role, {String? auditReason}) =>
      client._http._execute(BasicRequest._new(
          "/guilds/${this.guildId.toString()}/members/${this.id.toString()}/roles/${role.id.toString()}",
          method: "DELETE",
          auditLog: auditReason));

  /// Kicks the member from guild
  @override
  Future<void> kick({String? auditReason}) =>
      client._http._execute(
          BasicRequest._new("/guilds/${this.guildId}/members/${this.id}", method: "DELETE", auditLog: auditReason));

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  @override
  Future<void> edit(
      {String? nick, List<IRole>? roles, bool? mute, bool? deaf, VoiceChannel? channel, String? auditReason}) {
    final body = <String, dynamic>{
      if (nick != null) "nick": nick,
      if (roles != null) "roles": roles.map((f) => f.id.toString()).toList(),
      if (mute != null) "mute": mute,
      if (deaf != null) "deaf": deaf,
      if (channel != null) "channel_id": channel.id.toString()
    };

    return client._http._execute(BasicRequest._new("/guilds/${this.guildId.toString()}/members/${this.id.toString()}",
        method: "PATCH", auditLog: auditReason, body: body));
  }

  @override
  String toString() => super.toString();
}

/// A user with [Guild] context.
class CacheMember extends CachelessMember implements GuildEntity {
  /// The guild that the member is a part of.
  @override
  Guild guild;

  /// Returns highest role for member
  IRole get highestRole => this.roles.isEmpty ? guild.everyoneRole : roles.reduce((f, s) => (f as Role).position > (s as Role).position ? f : s);

  /// Color of highest role of user
  DiscordColor get color => (highestRole as Role).color;

  /// Voice state of member
  VoiceState? get voiceState => guild.voiceStates[this.id];

  /// Returns total permissions of user.
  Permissions get effectivePermissions {
    if (this == guild.owner) {
      return Permissions.all();
    }

    var total = (guild.everyoneRole as Role).permissions.raw;
    for (final role in roles) {
      if(role is! Role) {
        continue;
      }

      total |= role.permissions.raw;

      if (PermissionsUtils.isApplied(total, PermissionsConstants.administrator)) {
        return Permissions.fromInt(PermissionsConstants.allPermissions);
      }
    }

    return Permissions.fromInt(total);
  }

  // TODO: Remove duplicate
  @override
  bool _updateMember(String? nickname, List<IRole> roles) => super._updateMember(nickname, roles);

  factory CacheMember._standard(Map<String, dynamic> data, Guild guild, Nyxx client) =>
      CacheMember._new(data, data["user"] as Map<String, dynamic>, guild, client);

  factory CacheMember._fromUser(Map<String, dynamic> dataUser, Map<String, dynamic> dataMember, Guild guild, Nyxx client) =>
      CacheMember._new(dataMember, dataUser, guild, client);

  CacheMember._new(Map<String, dynamic> raw, Map<String, dynamic> user, this.guild, Nyxx client) : super._new(raw, user, guild.id, client) {
    this.roles = [
      for(final role in this.roles)
        // TODO: NNBD
        this.guild.roles[role.id]!
    ];
  }
}
