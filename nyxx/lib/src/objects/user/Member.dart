part of nyxx;

// TODO: Do something
// Two classes to simplify Member class itself. Maybe it's over-engineered but at least there is no _cons method anymore

class _StandardMember extends Member {
  _StandardMember(Map<String, dynamic> data, Guild guild, Nyxx client)
      : super._new(data, data['user'] as Map<String, dynamic>, guild, client);
}

class _ReverseMember extends Member {
  _ReverseMember(Map<String, dynamic> data, Guild guild, Nyxx client)
      : super._new(data['member'] as Map<String, dynamic>, data, guild, client);
}

/// A user with [Guild] context.
abstract class Member extends User implements GuildEntity {
  /// The member's nickname, null if not set.
  String? nickname;

  /// When the member joined the guild.
  late final DateTime joinedAt;

  /// Weather or not the member is deafened.
  late final bool deaf;

  /// Weather or not the member is muted.
  late final bool mute;

  /// A list of [Role]s the member has.
  late List<Role> roles;

  /// The highest displayed role that a member has, null if they don't have any
  Role? hoistedRole;

  @override

  /// The guild that the member is a part of.
  Guild guild;

  /// Returns highest role for member
  Role get highestRole => roles.isEmpty
      ? guild.everyoneRole
      : roles.reduce((f, s) => f.position > s.position ? f : s);

  /// Color of highest role of user
  DiscordColor get color => highestRole.color;

  /// Voice state of member
  VoiceState? get voiceState => guild.voiceStates[this.id];

  /// Returns total permissions of user.
  Permissions get effectivePermissions {
    if (this == guild.owner) return Permissions.all();

    var total = guild.everyoneRole.permissions.raw;
    for (var role in roles) {
      total |= role.permissions.raw;

      if (PermissionsUtils.isApplied(total, PermissionsConstants.administrator))
        return Permissions.fromInt(PermissionsConstants.allPermissions);
    }

    return Permissions.fromInt(total);
  }

  Member._new(Map<String, dynamic> raw, Map<String, dynamic> user, this.guild,
      Nyxx client)
      : super._new(user, client) {
    this.nickname = raw['nick'] as String;
    this.deaf = raw['deaf'] as bool;
    this.mute = raw['mute'] as bool;

    this.roles = [];
    raw['roles'].forEach((i) {
      this.roles.add(guild.roles[Snowflake(i)]);
    });

    if(raw['hoisted_role'] != null && roles.isNotEmpty) {
      this.hoistedRole = this.roles.firstWhere((element) => element.id == Snowflake(raw['hoisted_role']), orElse: () => null);
    }

    if (raw['joined_at'] != null)
      this.joinedAt = DateTime.parse(raw['joined_at'] as String).toUtc();

    if (raw['game'] != null)
      this.presence = Presence._new(raw['game'] as Map<String, dynamic>);
  }

  /// Checks if member has specified role. Returns true if user is assigned to given role.
  bool hasRole(bool func(Role role)) => this.roles.any(func);

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban(
      {int deleteMessageDays = 0,
      String? reason,
      String auditReason = ""}) async {
    await client._http.send('PUT', "/guilds/${this.guild.id}/bans/${this.id}",
        body: {"delete-message-days": deleteMessageDays, "reason": reason},
        reason: auditReason);
  }

  /// Adds role to user
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(Role role, {String auditReason = ""}) {
    return client._http.send(
        'PUT', '/guilds/${guild.id}/members/${this.id}/roles/${role.id}',
        reason: auditReason);
  }

  /// Removes [role] from user.
  Future<void> removeRole(Role role, {String auditReason = ""}) {
    return client._http.send("DELETE",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}/roles/${role.id.toString()}",
        reason: auditReason);
  }

  /// Kicks the member from guild
  Future<void> kick({String auditReason = ""}) async {
    await client._http.send(
        'DELETE', "/guilds/${this.guild.id}/members/${this.id}",
        reason: auditReason);
  }

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  Future<void> edit(
      {String? nick,
      List<Role>? roles,
      bool? mute,
      bool? deaf,
      VoiceChannel? channel,
      String auditReason = ""}) {
    var req = Map<String, dynamic>();
    if (nick != null) req["nick"] = nick;
    if (roles != null)
      req['roles'] = roles.map((f) => f.id.toString()).toList();
    if (mute != null) req['mute'] = mute;
    if (deaf != null) req['deaf'] = deaf;
    if (channel != null) req['channel_id'] = channel.id.toString();

    return client._http.send("PATCH",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}",
        body: req, reason: auditReason);
  }

  @override
  String toString() => super.toString();
}
